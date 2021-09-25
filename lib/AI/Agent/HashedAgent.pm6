use v6.c;

use AI::Agent::Actor;
use AI::Agent::Agent;

class AI::Agent::HashedAgent is AI::Agent::Agent
{
	has $.status;
	has &!callback;
	has AI::Agent::Agent @!dependencies;
	has Bool $.done;

	submethod BUILD(:$status) {
		$!status = $status;
		self.add-depedency(self.ask);
		self.add-depedency(self.agent);
	}

	method add-dependency(AI::Agent::Agent $dependency) {
    		push @!dependencies, $dependency;
	}

	method ask(%args) {
		return qq:to/RET/:
    You can ask me the following:
			agent, dispatch args = \{ "agent", Agent instance \}
RET

		$.status = 1;

	}

	# agent dispatched, overload for other agent parsing
	method dispatch_agent($agent) {
		return &$agent.dispatch;
	}

	# Look if an agent is dispatched, note the "agent" key for agents
	method agent(%args) {
		%args{"agent"}.dispatch_agent(self);
		$.status = 1;
	}

	### main call to the actor-agent

	method dispatch($message, %optargs) {
    		unless $!done {
        		self.dispatch($message, %optargs) for @!dependencies;
        		&!callback();
        		$!done = True;
    		}
        	$!done = False;
		$.status = 0;
	}

}
