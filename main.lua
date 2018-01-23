gui = {}

function love.load()
    gridXCount = 40;
    gridYCount = 25;

    love.window.setMode(40 * 15, 30 * 15);
    love.window.setTitle("Better Snake");
    
    icon = love.image.newImageData("images/snake_icon.jpg");
    love.window.setIcon(icon);

    gui.best_score = 0;
    cellSize = 15;

        snakeSegments = {
            {x = 3, y = 4},
            {x = 2, y = 4},
            {x = 1, y = 4},
        }

        function moveFood()
    local possibleFoodPositions = {}

        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true;

                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false;
                    end
                    
                    -- this just makes sure the food random change is on the board and to make sure it doesn't spawn in the snake.
                    
                    if (foodY < 4 or foodY > (30 * 15) - 45) then
                      possible = false;
                      end
                end

                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        foodPosition = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]
    end

    moveFood();

    function reset()
        snakeSegments = {
            {x = 3, y = 4},
            {x = 2, y = 4},
            {x = 1, y = 4},
        }
        
        directionQueue = {'right'} -- the starting movement is right.
        snakeAlive = true;
        gui.score = 0;
        timer = 0;
        gui.timer = 0;
        gameTimer = 0;
        gui.score = 0; -- resetting the score  

        moveFood();       
    end

    reset();
end

function love.update(dt)
    timer = timer + dt;
    
    gameTimer = gameTimer + dt;

    if snakeAlive then
         if (gameTimer >= 1) then
           gui.timer = gui.timer + 1;
           gameTimer = 0;
           end
         
      
        local timerLimit = 0.06; -- snake speed
        if timer >= timerLimit then
            timer = timer - timerLimit;

            if #directionQueue > 1 then
                table.remove(directionQueue, 1);
            end

            local nextXPosition = snakeSegments[1].x;
            local nextYPosition = snakeSegments[1].y;

            if directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1;
                if nextXPosition > gridXCount then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end
                
            elseif directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1;
                if nextXPosition < 1 then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end
                
                -- all this stuff is collision
                
            elseif directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1;
                if nextYPosition > (gridYCount + 3) then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end
                
            elseif directionQueue[1] == 'up' then
                nextYPosition = nextYPosition - 1;
                if nextYPosition < 4 then
                    table.remove(snakeSegments);
                    snakeAlive = false;
                end
            end

            local canMove = true;

            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments
                and nextXPosition == segment.x 
                and nextYPosition == segment.y then -- this stops the player going back on itself
                    canMove = false;
                end
            end

            if canMove then
                table.insert(snakeSegments, 1, {x = nextXPosition, y = nextYPosition})

                if snakeSegments[1].x == foodPosition.x
                and snakeSegments[1].y == foodPosition.y then
                    moveFood();
                    gui.score = gui.score + 10;
                    
                    if (gui.score > gui.best_score) then
                      gui.best_score = gui.score;
                      end
                else
                    table.remove(snakeSegments);
                end
            else
                snakeAlive = false;
            end
        end
    elseif timer >= 1.5 then
        reset(); -- when the snake dies, the timer stops. if the timer has stopped for 1.5 seconds, restart the game.
    end
end

function createGameWindow()
  love.graphics.setColor(28, 28, 28);
  love.graphics.rectangle('fill', 0, 45, gridXCount * cellSize , (gridYCount * cellSize)); -- The Game Window
  end

function love.draw()
    local cellSize = 15;

    createGameWindow();

    local function drawCell(x, y)
        love.graphics.rectangle('fill', (x - 1) * cellSize, (y - 1) * cellSize, cellSize - 1, cellSize - 1); -- draw entity function
    end

    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(173, 255, 47); -- snake colour
        else
            love.graphics.setColor(70, 70, 70); -- dead snake colour
        end
        drawCell(segment.x, segment.y); -- draw snake
    end

    love.graphics.setColor(255, 0, 0); -- food colour
    drawCell(foodPosition.x, foodPosition.y);
    
    drawGUI();
end

function love.keypressed(key)
    if (key == "right" or key == "d")
    and directionQueue[#directionQueue] ~= 'right'
    and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')

    elseif (key == "left" or key == "a")
    and directionQueue[#directionQueue] ~= 'left'
    and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')

   -- This is handling key presses.

    elseif (key == "up" or key == "w")
    and directionQueue[#directionQueue] ~= 'up'
    and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')

    elseif (key == "down" or key == "s")
    and directionQueue[#directionQueue] ~= 'down'
    and directionQueue[#directionQueue] ~= 'up' then
        table.insert(directionQueue, 'down')
    end
end

function drawGUI()
  
  love.graphics.setColor(255, 255, 255);
  font = love.graphics.newFont(28);
  love.graphics.setFont(font);
  love.graphics.print("- SNAKE -", 235, 5);
  
  font = love.graphics.newFont(15); -- font size+
  love.graphics.setFont(font);
  
  love.graphics.print("Score: " .. tostring(gui.score), 50, 425);
  love.graphics.print("Timer: " .. tostring(gui.timer), 270, 425);
  love.graphics.print("Best Score: " .. tostring(gui.best_score), 450, 425);
  
  end