extends Node

const Keys: Dictionary = {
	Messages = "messages",
	Recipient = "recipient",
	Message = "message",
	Attachments = "attachments",
	AttachmentImage = "image"
}


## Sends "message" to "recipient" with optional "metadata"
## (e.g. {jpg : [[PackedByteArray]]} will send an image along with the message). 
##Message is shown as being from "sender". "recipient" can be a player
func send_message(sender: String, recipient: String, message: String, metadata: Dictionary = {}):
	pass
