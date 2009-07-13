(plugin
 :name "autojoin"
 :hooks (irc-rpl_welcome-message)
 :action #.(lambda (message)
	     (join (connection message)
		   (conf-value "channels" *conf*))))