require 'rubygems'

#Jabber::debug = true

module Botfly
  class Bot
    attr_reader :responders, :client
    def initialize(jid,pass)
      Botfly.logger.info("  BOT: Bot#new")
      @password = pass
      @jid = Jabber::JID.new(jid)
      @client = Jabber::Client.new(@jid)
      @responders = {}
    end
  
    def on
      Botfly.logger.info("  BOT: Bot#on")
      responder = Botfly::Responder.new(@client, self)
      return responder
    end
    
    def connect
      Botfly.logger.info("  BOT: Connecting to #{@jid}...")
      @client.connect
      @client.auth(@password)
      Botfly.logger.info("  BOT: Connected")
      register_for_xmpp_callbacks
      @client.send(Jabber::Presence.new.set_status("Carrier has arrived"))
      #Thread.stop
    end
    
    def add_responder_of_type(type, responder)
      Botfly.logger.debug("  BOT: Added responder of type #{type.inspect}")
      @responders[type] ||= [] 
      @responders[type] << responder
    end
      
  private

    def register_for_xmpp_callbacks
      Botfly.logger.info("  BOT: Registering for callbacks with client")
#     @client.add_update_callback {|presence| respond_to(:update, :presence => presence) }
#     @client.add_subscription_request_callback {|item, pres| } # requires Roster helper
      @client.add_message_callback do |message| 
        Botfly.logger.debug("    CB: Got Message") 
        respond_to(:message, :message => message)
      end
      @client.add_presence_callback do |old_presence,new_presence| 
        Botfly.logger.debug("    CB: Got Presence")
        respond_to(:presence, :old => old_presence, :new => new_presence)
      end

    end
    
    def respond_to(callback_type, params)
      Botfly.logger.info("  BOT: Responding to callback of type: #{callback_type}")
      responders = params[:muc] ? @muc_responders[params[:muc]] : @responders
      responders[callback_type].each {|r| r.callback_with params} if responders[callback_type]
    end
    
#    def register_for_muc_callbacks(client)
#      params = {:muc => client}
##      client.on_join {|time,nick| respond_to(:join, params.merge!(:time=>time,:nick=>nick))}
#      client.on_leave {|time,nick| respond_to(:leave, params.merge!(:time=>time,:nick=>nick))}
#      client.on_message {|time,nick,text| respond_to(:message, params.merge!(:time=>time,:nick=>nick,:text=>text))}
#      client.on_private_message {|time,nick,text| respond_to(:private_message,    params.merge!(:time=>time,:nick=>nick,:text=>text))}
#      client.on_room_message {|time,text| respond_to(:room_message, params.merge!(:time => time, :text => text))}
#      client.on_self_leave {|time| respond_to(:self_leave, params.merge!(:time => time)) }
#      client.on_subject {|time,nick,subject| respond_to(:subject, params.merge!(:time => time, :nick => nickname, :subject => subject))}
#    end    
        
  end
end