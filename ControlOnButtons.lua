local component = require("component")
local event = require("event")
local gpu = component.gpu
local address = "86cafc04-df76-4805-bc15-250eff91dced"
local reactor = component.reactor_chamber
local redstone = component.proxy(address) -- Обращение к красному контроллеру при помощи уже заданного адреса
local term = require("term")

local redstoneInput
local redstoneInputSide = 4 -- Указать сторону блока красного контроллера
local buttons = {}  -- Список кнопок
local temperature = 0  -- Исходное значение температуры

-- Функция для получения текущей температуры реактора
local function getReactorHeat()
    local reactorHeat = reactor.getHeat()
    reactorHeat = reactorHeat/100 -- Преобразование в сотые доли, как в реакторе. Грубо говоря, видим проценты, а не рандомное огромное значение
    return reactorHeat -- Возвращаем переменную на вывод
  end

-- Функция для очистки экрана
local function clearScreen()
  local screenWidth, screenHeight = gpu.getResolution()
  gpu.setBackground(0x000000)  -- Черный цвет для заполнения экрана
  gpu.fill(1, 1, screenWidth, screenHeight, " ")
end

-- Функция для рисования кнопки
local function drawButton(button)
  gpu.setBackground(button.bgColor)
  gpu.setForeground(button.textColor)
  gpu.fill(button.x, button.y, button.width, button.height, " ")
  gpu.set(button.x + 1, button.y + 1, button.label)
end

-- Функция для обновления значения на кнопке
local function updateButtonLabel(button, value)
  button.label = value
  drawButton(button)
end
 
-- Функция для добавления кнопки
local function addButton(label, x, y, width, height, bgColor, textColor, callback)
  local button = {
    label = label,
    x = x,
    y = y,
    width = width,
    height = height,
    bgColor = bgColor,
    textColor = textColor,
    callback = callback
  }
  table.insert(buttons, button)
  drawButton(button)
end

-- Функция для обработки событий
local function handleEvents(_, _, x, y, button)
  for _, button in ipairs(buttons) do
    if x >= button.x and x <= button.x + button.width - 1 and y >= button.y and y <= button.y + button.height - 1 then
      button.callback()
      break
    end
  end
end

-- Функция для включения реактора
local function activateReactor()
    -- os.execute("cls") -- Очищаем экран от мусора, чтобы не допустить наложения
    if reactor.producesEnergy() then -- Дословно, если реактор вырабатывает энергию, то...
      -- print("Реактор уже включен")
    else -- Если же реактор НЕ вырабатывает энергию
      -- Установим высокий уровень сигнала redstone на указанном порту
      redstone.setOutput(redstoneInputSide, 15)
      redstone.setBundledOutput(redstoneInputSide, {0, 0, 0, 0, 0, 0, 0, 0}) -- Устанавливаем все стороны на 0
      os.sleep(0.1) -- Даем немного времени для обработки сигнала
      local redstoneOutput = redstone.getOutput(redstoneInputSide)
      if redstoneOutput > 0 then
        -- print("Реактор включен")
        reactorActive = true -- Устанавливаем флаг reactorActive в true
      else
        -- print("Не удалось включить реактор") -- В случае непредвиденных проблем
      end
      -- Ждем 1 секунду, чтобы реактор успел включиться
      os.sleep(1)
    end
  end
  
  -- Функция для выключения реактора
  local function deactivateReactor()
    -- os.execute("cls") -- Очищаем экран от мусора, чтобы не допустить наложения
    if not reactor.producesEnergy() then -- Если не производит энергию, то
      -- print("Реактор уже выключен")
    else -- Если же производит энергию
      -- Установим низкий уровень сигнала redstone на указанном порту
      redstone.setOutput(redstoneInputSide, 0)
      redstone.setBundledOutput(redstoneInputSide, {0, 0, 0, 0, 0, 0, 0, 0}) -- Устанавливаем все стороны на 0
      os.sleep(0.1) -- Даем немного времени для того, чтобы обработать команду
      -- print("Реактор выключен")
      reactorActive = false -- Исправление: устанавливаем флаг reactorActive в false
      -- Ждем 1 секунду, чтобы реактор успел выключиться
      os.sleep(1)
    end
  end

-- Функция-обработчик для первой кнопки
local function buttonCallback()
  gpu.set(1, 10, "Button was clicked!")
end

local function button2Callback()
    gpu.set(1, 10, "Реактор включен")
    activateReactor()
end

local function button3Callback()
    gpu.set(1, 10, "Реактор выключен")
    deactivateReactor()
end

-- Очищаем экран перед созданием кнопок
clearScreen()

-- Добавляем первую кнопку
addButton(tostring(temperature), 1, 1, 10, 3, 0xFFFFFF, 0x000000, buttonCallback)

-- Добавляем вторую кнопку справа от первой
addButton("Включить", 12, 1, 10, 3, 0xFFFFFF, 0x000000, button2Callback)

addButton("Выключить", 23, 1, 10, 3, 0xFFFFFF, 0x000000, button3Callback)

-- Регистрируем обработчик событий нажатия мыши
event.listen("touch", handleEvents)

-- Реализация изменения значения температуры (тестово)
-- Вместо этого вам нужно добавить свою логику для получения и обновления значения температуры
-- В данном примере используется случайный генератор чисел
math.randomseed(os.time())
while true do
  -- Генерируем случайное значение температуры
  temperature = getReactorHeat()
  -- Обновляем значение на кнопке
  updateButtonLabel(buttons[1], tostring(temperature))
  -- Задержка перед следующим обновлением значения температуры
  os.sleep(1)
end
