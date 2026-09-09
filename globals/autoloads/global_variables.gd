extends Node

const MESSAGES_PROP_KEY: String = "messages"
const MESSAGE_FONT_SIZE: int = 32
const MESSAGE_SENDER_FONT_SIZE: int = 40

var logged_in: bool = false
var using_email_verification: bool = false
var session_not_found: bool = false 

# Not stored for anything except Talo requests that require the users password.
var users_password: String = ""
