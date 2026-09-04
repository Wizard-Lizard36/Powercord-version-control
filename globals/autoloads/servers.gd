extends Node

const Keys: Dictionary = {
	Messages = "messages",
	Recipient = "recipient",
	Message = "message",
	Attachments = "attachments",
	AttachmentImage = "image"
}

var servers: Dictionary[String, TaloChannel] = {}
