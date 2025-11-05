How to format levels:

Names of folders must match a record found in "add_songs_here.txt".

Each folder should have four files, three of which are required:
cover.png
info.json -- Required
level.json -- Required
song.wav -- Required

info.json is a json composed of statistics and facts about the song. They willbe displayed along with other facts about the song on the menu.
info.json MUST have at least a "title" field, but other fields are optional.

level.json is a json containing timestamps and events that must happen at each timestamp.
Shown below is an example:
{
    "10.5" : {
        "enm": {
            "1":{
                "dir": "u",
                "dmg": "0.3",
                "time": "3"
            },
            "2":{
                "dir": "l",
                "dmg": "0.5",
                "time": "4"
            }
        },
        "lsr": {
            "1": {
                "dmg" : "0.1",
                "0" : "dd",
                "1" : "dd",
                "3" : "90",
                "5" : "del"
            },
            "2": {
                "dmg" : "0.2",
                "0" : "du",
                "1" : "hz",
                "3" : "-90",
                "5" : "del"
            }
        }
    }
}

The timestamp is 10.5, meaning this will all happen 10.5 seconds after starting the level.
"enm" and "lsr" stand for enemy and laser, respectively.
In enemy, the "1" and "2" stand for the identifier of each enemy.
Each enemy will have fields "dir", "dmg" and "time".
Dir stands for direction and will be where the player will have to be to hit the enemy, and can be "u" (up), "d" (down), "l" (left), "r" (right)
Dmg stands for damage and is how much damage the player will take if they miss hitting the enemy and it reaches the middle, with 1 being the entirety of the player's health.
Time is how much time will elapse from the block spawning until it despawns and hurts the player.

Under lsr, 1 and 2 mean the same thing as enm, where 1 and 2 are identifiers for the lasers.
Under each instance of the laser, there are a few fields.
"dmg" does a similar thing to the dmg field from "enm", but is instead dealt continuously per second to the player while they are colliding with the laser.
The numbers are sub-time stamps, where each event that is given will happen that far from the timestamp in which the laser was created.
For example, in instance "2", "0" means the laser starts with the given event, which is "du" (explained in a few lines), and "1" means one second from the creation of this laser, the event will be "hz".

The given events stand for diagonal-up and horizontal, which correspond to the rotation of the laser. The available options are:
du - diagonal up (/)
dd - diagonal down (\)
hz - horizontal (-)
vt - vertical(|)
any number - rotate X degrees by the time this timestamp hits.

Finally, del means delete, which removes the laser.

song.wav must be present as it will contain the music data which will be played during the level.