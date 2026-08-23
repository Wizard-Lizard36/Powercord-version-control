extends Node

const IMAGE_QUALITY = 0.75

const Keys: Dictionary = {
	Messages = "messages",
	Recipient = "recipient",
	Message = "message",
	Attachments = "attachments",
	AttachmentImage = "image"
}

	
	#SilentWolf.Scores.save_score("Hello there cheesy", 1000000, "main", {"message" : "Hi My Name is cheesemcCheese🍔".to_utf8_buffer()})
	#
	#await get_tree().create_timer(0.1).timeout
	#
	#var scores: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	#print(scores)
	#if scores.success:
		#for score_info in scores.scores:
			#print(score_info.player_name + "'s score is %s!" % score_info.score)
			#SilentWolf.Scores.delete_score(score_info.score_id)

## Sends "message" to "recipient" with optional "image".
## Message is shown as being from "sender".
func send_message(sender: String, recipient: String, message: String, image: Image = null):
	SilentWolf.Scores.save_score(
			sender, 0, Keys.Messages, {Keys.Recipient : recipient, Keys.Message : message.to_utf8_buffer(),
			Keys.Attachments : {Keys.AttachmentImage : image.save_jpg_to_buffer(IMAGE_QUALITY) if image else PackedByteArray([])}}
			)
