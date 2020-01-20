# Bowling [![CircleCI](https://circleci.com/gh/ayrat-playground/bowling.svg?style=svg)](https://circleci.com/gh/ayrat-playground/bowling)

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Description

This application allows to keep score of a bowling game

### Endpoints


- POST /api/v1/games. It doesn't accept any parameters

- GET  /api/v1/games/:game_id/score. Calculates the score. It doesn't accept any parameters

- POST /api/v1/games/:game_id/frames/:frame_id/throws. It acceps the `value` of the next throw.


### How-TO

- Create a new bowling game.

``` bash
curl -X POST http://localhost:4000/api/v1/games

{"uuid":"a7d58743-8e09-427a-a993-300aa12a8ed4","frames":[]}%
```

- Create a new throw

Let's create the first throw in the first frame.

``` bash
curl -H "Content-Type: application/json" -X POST -d '{"value": 5}' http://localhost:4000/api/v1/games/a7d58743-8e09-427a-a993-300aa12a8ed4/frames/1/throws

{"value":5,"number":0}
```


Let's create the second throw in the first frame.

``` bash
curl -H "Content-Type: application/json" -X POST -d '{"value": 5}' http://localhost:4000/api/v1/games/a7d58743-8e09-427a-a993-300aa12a8ed4/frames/1/throws

{"value":5,"number":1}

```

Let's create a strike in the second frame.

``` bash
curl -H "Content-Type: application/json" -X POST -d '{"value": 10}' http://localhost:4000/api/v1/games/a7d58743-8e09-427a-a993-300aa12a8ed4/frames/2/throws

{"value":10,"number":0}
```

Let's two more throws in the third frame

``` bash
curl -H "Content-Type: application/json" -X POST -d '{"value": 5}' http://localhost:4000/api/v1/games/a7d58743-8e09-427a-a993-300aa12a8ed4/frames/3/throws

{"value":5,"number":0}

curl -H "Content-Type: application/json" -X POST -d '{"value": 2}' http://localhost:4000/api/v1/games/a7d58743-8e09-427a-a993-300aa12a8ed4/frames/3/throws

{"value":2,"number":1}
```

Let's calculate the score after three frames.

``` bash
curl http://localhost:4000/api/v1/games/a7d58743-8e09-427a-a993-300aa12a8ed4/score

{"1":20,"2":37,"3":44}
```
