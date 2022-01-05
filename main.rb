require "mongo"
require "discordrb"

require_relative "lib/spikey"

spikey = Spikey.new(ENV["token"], ENV["mongouri"])


spikey.on_ready { spikey.ready }


spikey.server_create { |event| spikey.joined_server(event) }
spikey.server_delete { |event|  spikey.left_server(event)  }


spikey.member_join  { |event| spikey.log_member_joined(event) }
spikey.member_leave { |event|  spikey.log_member_left(event)  }

spikey.member_banned   { |event|  spikey.log_member_ban(event)  }
spikey.member_unbanned { |event| spikey.log_member_unban(event) }

spikey.message_edit   { |event|  spikey.log_message_edit(event)  }
spikey.message_delete { |event| spikey.log_message_delete(event) }


spikey.command(:help, max_args: 1) { |event, category| spikey.help(event, category) }

spikey.command(:config_logs, max_args: 1) { |event, channel| spikey.config_logs(event, channel) }


spikey.run
