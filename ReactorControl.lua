local component = require("component")
-- local address = "<86cafc04-df76-4805-bc15-250eff91dced>"
local event = require("event")
local reactor = component.reactor_chamber
local redstone = component.redstone
-- local redstone = component.proxy(address)
local term = require("term")

local redstoneInput

local redstoneInputSide = 4  -- Порт, к которому подключен компонент redstone

-- Функция для увеличения размера текста
local function setFontSize(size)
  term.gpu().setResolution(size, size)
end

-- Установка размера текста на 20 (измените на нужное значение)
--setFontSize(20)

-- Проверка на наличие компонента redstone
if not redstone then
  print("Компонент redstone не найден")
  return
end

-- Функция для позиционирования курсора на экране
local function setCursor(x, y)
  io.write(string.format("\27[%d;%dH", y, x))
  io.flush()
end

-- Функция для обновления значений переменных на экране
local function updateValues()
  -- Обновляем показатели реактора, оставляя текст на экране
  setCursor(1, 2)
  io.write("Базовая выработка энергии реактора: " .. reactor.getReactorEUOutput() .. " EU/t")
  --setCursor(1, 4)
  --io.write("Текущий выход энергии реактора: " .. reactor.getReactorEnergyOutput())
  setCursor(1, 3)
  io.write("Текущая температура реактора: " .. reactor.getHeat())
  setCursor(1, 4)
  io.write("Максимальная температура реактора: " .. reactor.getMaxHeat())
  --io.flush()
end

-- Функция для включения реактора
local function activateReactor()
  os.execute("cls")
  if reactor.producesEnergy() then
    print("Реактор уже включен")
  else
    -- Установим высокий уровень сигнала redstone на указанном порту
    redstone.setOutput(redstoneInputSide, 15)
    redstone.setBundledOutput(redstoneInputSide, {0, 0, 0, 0, 0, 0, 0, 0}) -- устанавливаем все цвета на 0
    os.sleep(0.1) -- Даем немного времени для установки высокого сигнала
    local redstoneOutput = redstone.getOutput(redstoneInputSide)
    if redstoneOutput > 0 then
      print("Реактор включен")
      reactorActive = true -- Исправление: устанавливаем флаг reactorActive в true
    else
      print("Не удалось включить реактор")
    end
    -- Ждем 1 секунду, чтобы реактор успел включиться
    os.sleep(1)
  end
end

-- Функция для выключения реактора
local function deactivateReactor()
  os.execute("cls")
  if not reactor.producesEnergy() then
    print("Реактор уже выключен")
  else
    -- Установим низкий уровень сигнала redstone на указанном порту
    redstone.setOutput(redstoneInputSide, 0)
    redstone.setBundledOutput(redstoneInputSide, {0, 0, 0, 0, 0, 0, 0, 0}) -- устанавливаем все цвета на 0
    os.sleep(0.1) -- Даем немного времени для установки низкого сигнала
    print("Реактор выключен")
    reactorActive = false -- Исправление: устанавливаем флаг reactorActive в false
    -- Ждем 1 секунду, чтобы реактор успел выключиться
    os.sleep(1)
  end
end


-- Функция для очистки экрана
local function clearScreen()
  os.execute("cls")   -- Для OpenOS
end

-- Функция для проверки состояния реактора
local function checkReactorStatus()
  local status = ""
  if reactor.producesEnergy() then
    status = "Реактор включен"
  else
    status = "Реактор выключен"
  end
  return status
end

-- Функция для получения базовой выработки энергии реактора
local function getReactorEUOutput()
  local euOutput = reactor.getReactorEUOutput()
  -- print("Базовая выработка энергии реактора: " .. math.floor(euOutput) .. " EU/t")
  return euOutput
end

-- Функция для получения текущей температуры реактора
local function getReactorHeat()
  local reactorHeat = reactor.getHeat()
  reactorHeat = reactorHeat/100 -- Преобразование в сотые доли, как в реакторе
  return reactorHeat
end

-- Функция для получения максимальной температуры реактора
local function getMaxReactorHeat()
  local maxReactorHeat = reactor.getMaxHeat()
  --print("Максимальная температура реактора: " .. maxReactorHeat)
  return maxReactorHeat
end

-- Основной цикл программы
local reactorActive = false -- Флаг, указывающий, включен ли реактор или выключен
local running = true -- Флаг, указывающий, запущена ли программа

while running do
  -- Проверяем состояние реактора и получаем текущие значения переменных
  local reactorStatus = checkReactorStatus()
  local reactorEUOutput = getReactorEUOutput()
  -- local reactorEnergyOutput = getReactorEnergyOutput()
  local reactorHeat = getReactorHeat()
  local maxReactorHeat = getMaxReactorHeat()
  
  setCursor(1, 1)
  io.write("Состояние реактора:")
  setCursor(1, 2)
  io.write("Базовая выработка энергии реактора: ")
  -- setCursor(1, 3)
  -- io.write("Текущий выход энергии реактора: " .. reactorEnergyOutput)
  setCursor(1, 3)
  io.write("Текущая температура реактора: ")
  setCursor(1, 4)
  io.write("Максимальная температура реактора: ")
  setCursor(1, 5)
  io.flush()
  
  -- Обновляем только значения переменных на экране, оставляя текст на месте
  setCursor(1, 1)
  io.write("Состояние реактора:" .. reactorStatus)
  setCursor(1, 2)
  io.write("Базовая выработка энергии реактора: " .. reactorEUOutput .. " EU/t")
  -- setCursor(1, 3)
  -- io.write("Текущий выход энергии реактора: " .. reactorEnergyOutput)
  setCursor(1, 3)
  io.write("Текущая температура реактора: " .. reactorHeat)
  setCursor(1, 4)
  io.write("Максимальная температура реактора: " .. maxReactorHeat)
  setCursor(1, 5)
  io.flush()

  --updateValues()

  if reactorHeat and reactorActive then
      -- Проверка на перегрев реактора
      if reactorHeat > 60 then
        deactivateReactor() -- Выключаем реактор при превышении температуры
        print("Реактор перегрелся!")
        running = false -- Остановка программы без выхода
      end
    end

  -- Запрашиваем ввод пользователя, если есть
  local _, _, _, key = event.pull(0, "key_up")
  --os.sleep(1)
  
  if key == 0x18 then
    activateReactor()    -- Включаем реактор при нажатии клавиши "O"
  elseif key == 0x2E then
    deactivateReactor()  -- Выключаем реактор при нажатии клавиши "C"
  elseif key == 0x10 then
	clearScreen()
    running = false -- Выходим из программы при нажатии клавиши "Q"
  end

  -- Ждем 1 секунду перед следующей проверкой реактора
  --os.sleep(1)
end