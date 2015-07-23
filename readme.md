# t3

t3 is a multiplayer tic tac tow game written in ruby and javascript. It supports unlimited concurrent games with two players in each game. As tic tac tow is the lamest game ever created; in order to keep things interesting, the game ends when someone gets sick of tic tac tow. When the game is over the player with the least losses is the winner.

### Requirements
- Ruby (tested with 2.2.0)
- A browser that supports websockets

### Running

``` bash
bundle install
bundle exec ruby main.rb --host="localhost" --port=4567
```

### Options
``` bash
bundle exec ruby main.rb -h
```
