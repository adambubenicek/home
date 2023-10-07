if status is-login
	#exec bash -c "test -e /etc/profile && source /etc/profile;\
		#exec fish"
end

if status is-interactive
    set -gx fish_greeting
    set -gx SSH_AGENT_PID
    set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
end
