-- Inspired by FishDev

local pauseMusic = 'breakfast' -- music file in "sounds/"
local pauseIcons = {'maxPause', 'broPause'} -- image files in "images/"
local songEnd = 90
local optionSelected = 1
local option = {'Resume', 'Restart', 'Exit'}

function onPause()
    openCustomSubstate('pauseState', true);
    return Function_Stop;
end

function onCustomSubstateCreate(name)
    if name == 'pauseState' then
        -- Background fade
        makeLuaSprite('bgFade', nil, 0, 0)
        makeGraphic("bgFade", 1280, 720, '000000')
        setObjectCamera('bgFade', 'camOther')
        screenCenter('bgFade', 'xy')
        setProperty('bgFade.alpha', 0)
        addLuaSprite('bgFade', false)

        -- Background image
        makeLuaSprite('bar1', 'PAUSE/PAUSE bg', 0, 0)
        setObjectCamera('bar1', 'camOther')
        screenCenter('bar1', 'x')
        setProperty('bar1.alpha', 0)
        addLuaSprite('bar1', false)

        -- Music
        playSound(pauseMusic, 0, 'pauseSongTag')
        runTimer('loopPauseTag', songEnd, 0)
    end
end

function onCustomSubstateCreatePost(name)
    if name == 'pauseState' then

        doTweenAlpha("bgAlphaTween", "bgFade", 0.5, 0.4, 'linear')
        doTweenAlpha("barAlphaTween", "bar1", 1, 0.4, 'linear')

        -- Buttons
        for i, label in ipairs(option) do
            makeLuaText('option_'..i, label, 400, 150, 200 + (i - 1) * 100)
            setTextSize('option_'..i, 48)
            setTextAlignment('option_'..i, 'left')
            setObjectCamera('option_'..i, 'camOther')
            addLuaText('option_'..i)
        end

        updateOptionVisuals()
        playSound('clickText', 0.5)
        changeDiscordPresence("Paused", songName..' - ('..difficultyName..')', nil, 0, 0.0)
    end
end

function onCustomSubstateUpdatePost(name)
    if name == 'pauseState' then
        -- Movement
        if keyboardJustPressed('UP') or keyboardJustPressed('W') then
            chooseOption(-1)
            playSound('scrollMenu')
        elseif keyboardJustPressed('DOWN') or keyboardJustPressed('S') then
            chooseOption(1)
            playSound('scrollMenu')
        end

        -- Selection
        if keyboardJustPressed('ENTER') then
            playSound('clickText')
            if optionSelected == 1 then -- Resume
                stopPause()
            elseif optionSelected == 2 then -- Restart
                stopSound('pauseSongTag')
                restartSong(false)
            elseif optionSelected == 3 then -- Exit
                stopSound('pauseSongTag')
                exitSong(false)
            end
        end

        updateOptionVisuals()
    end
end

function updateOptionVisuals()
    for i = 1, #option do
        local color = (i == optionSelected) and 'FFFF00' or 'FFFFFF'
        setTextColor('option_'..i, color)
    end
end

function chooseOption(change)
    optionSelected = optionSelected + change
    if optionSelected > #option then
        optionSelected = 1
    elseif optionSelected < 1 then
        optionSelected = #option
    end
end

function stopPause()
    stopSound('pauseSongTag')
    cancelTimer('loopPauseTag')
    closeCustomSubstate()
    doTweenAlpha('bgFadeOut', 'bgFade', 0, 0.3, 'linear')
    doTweenAlpha('bar1Out', 'bar1', 0, 0.3, 'linear')
    doTweenAlpha('pauseIconOut', 'PauseIcon', 0, 0.3, 'linear')

    for i = 1, #option do
        doTweenAlpha('option_'..i..'_out', 'option_'..i, 0, 0.5, 'sineOut')
    end
end

function onTimerCompleted(tag)
    if tag == 'loopPauseTag' then
        playSound(pauseMusic, 1, 'pauseSongTag')
    end
end
