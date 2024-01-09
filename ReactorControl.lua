local component = require("component")
local address = "86cafc04-df76-4805-bc15-250eff91dced" -- Адресс красного контроллера
local event = require("event")
local reactor = component.reactor_chamber
--local redstone = component.redstone
local redstone = component.proxy(address) -- Обращение к красному контроллеру при помощи уже заданного адреса
local term = require("term")

local redstoneInput -- Так надо

local redstoneInputSide = 4  -- Порт (сторона), к которому подключен компонент redstone

-- Функция для увеличения размера текста (Делает экран квадратным)
--[[
local function setFontSize(size)
  term.gpu().setResolution(size, size)
end
]]

-- Установка размера текста на 20 (измените на нужное значение)
--setFontSize(20)

-- Проверка на наличие компонента redstone
if not redstone then
  print("Компонент redstone не найден")
  return -- Завершаем программу
end

-- Функция для позиционирования курсора на экране
local function setCursor(x, y)
  io.write(string.format("\27[%d;%dH", y, x))
  io.flush()
end

-- Функция для обновления значений переменных на экране (можно использовать в теле программы, но тут не доработано)
local function updateValues()
  -- Обновляем показатели реактора, оставляя текст на экране
  setCursor(1, 2)
  io.write("Базовая выработка энергии реактора: " .. reactor.getReactorEUOutput() .. " EU/t")
  setCursor(1, 3)
  io.write("Текущая температура реактора: " .. reactor.getHeat())
  setCursor(1, 4)
  io.write("Максимальная температура реактора: " .. reactor.getMaxHeat())
  -- io.flush()
end

-- Функция для включения реактора
local function activateReactor()
  os.execute("cls") -- Очищаем экран от мусора, чтобы не допустить наложения
  if reactor.producesEnergy() then -- Дословно, если реактор вырабатывает энергию, то...
    print("Реактор уже включен")
  else -- Если же реактор НЕ вырабатывает энергию
    -- Установим высокий уровень сигнала redstone на указанном порту
    redstone.setOutput(redstoneInputSide, 15)
    redstone.setBundledOutput(redstoneInputSide, {0, 0, 0, 0, 0, 0, 0, 0}) -- Устанавливаем все стороны на 0
    os.sleep(0.1) -- Даем немного времени для обработки сигнала
    local redstoneOutput = redstone.getOutput(redstoneInputSide)
    if redstoneOutput > 0 then
      print("Реактор включен")
      reactorActive = true -- Устанавливаем флаг reactorActive в true
    else
      print("Не удалось включить реактор") -- В случае непредвиденных проблем
    end
    -- Ждем 1 секунду, чтобы реактор успел включиться
    os.sleep(1)
  end
end

-- Функция для выключения реактора
local function deactivateReactor()
  os.execute("cls") -- Очищаем экран от мусора, чтобы не допустить наложения
  if not reactor.producesEnergy() then -- Если не производит энергию, то
    print("Реактор уже выключен")
  else -- Если же производит энергию
    -- Установим низкий уровень сигнала redstone на указанном порту
    redstone.setOutput(redstoneInputSide, 0)
    redstone.setBundledOutput(redstoneInputSide, {0, 0, 0, 0, 0, 0, 0, 0}) -- Устанавливаем все стороны на 0
    os.sleep(0.1) -- Даем немного времени для того, чтобы обработать команду
    print("Реактор выключен")
    reactorActive = false -- Исправление: устанавливаем флаг reactorActive в false
    -- Ждем 1 секунду, чтобы реактор успел выключиться
    os.sleep(1)
  end
end


-- Функция для очистки экрана, можно удобно использовать в программе
local function clearScreen()
  os.execute("cls")   -- Для OpenOS используется такая команда
end

-- Функция для проверки состояния реактора
local function checkReactorStatus()
  local status = "" -- Нужно ввести пустую переменную, чтобы переменная стала String
  if reactor.producesEnergy() then
    status = "Реактор включен"
  else
    status = "Реактор выключен"
  end
  return status -- Возвращаем переменную на вывод
end

-- Функция для получения базовой выработки энергии реактора
local function getReactorEUOutput()
  local euOutput = reactor.getReactorEUOutput()
  -- print("Базовая выработка энергии реактора: " .. math.floor(euOutput) .. " EU/t")
  return euOutput -- Возвращаем переменную на вывод
end

-- Функция для получения текущей температуры реактора
local function getReactorHeat()
  local reactorHeat = reactor.getHeat()
  reactorHeat = reactorHeat/100 -- Преобразование в сотые доли, как в реакторе. Грубо говоря, видим проценты, а не рандомное огромное значение
  return reactorHeat -- Возвращаем переменную на вывод
end

-- Функция для получения максимальной температуры реактора
local function getMaxReactorHeat()
  local maxReactorHeat = reactor.getMaxHeat()
  -- print("Максимальная температура реактора: " .. maxReactorHeat)
  return maxReactorHeat
end

-- Тело программы
local reactorActive = false -- Флаг, указывающий, включен ли реактор или выключен
local running = true -- Флаг, указывающий, запущена ли программа

while running do -- Цикл программы
  -- Проверяем состояние реактора и получаем текущие значения переменных
  local reactorStatus = checkReactorStatus() -- Статус реактора: включен/выключен
  local reactorEUOutput = getReactorEUOutput() -- Вырабатываемая энергия в EU/t
  local reactorHeat = getReactorHeat() -- Температура реактора в %
  local maxReactorHeat = getMaxReactorHeat() -- Максимальная температура реактора
  
  -- Первый раз прописываем строки БЕЗ значений, чтобы очистить прошлые выводимые значения
  setCursor(1, 1) -- Устанавливаем курсор
  io.write("Состояние реактора:")
  setCursor(1, 2)
  io.write("Базовая выработка энергии реактора: ")
  setCursor(1, 3)
  io.write("Текущая температура реактора: ")
  setCursor(1, 4)
  io.write("Максимальная температура реактора: ")
  setCursor(1, 5)
  io.flush() -- Работа с буфером. Не обязательная процедура. Была оставленна, т.к. так более стабильно.
  
  -- Обновляем только значения переменных на экране, оставляя текст на месте
  -- Выводим новые значения
  setCursor(1, 1)
  io.write("Состояние реактора:" .. reactorStatus)
  setCursor(1, 2)
  io.write("Базовая выработка энергии реактора: " .. reactorEUOutput .. " EU/t")
  setCursor(1, 3)
  io.write("Текущая температура реактора: " .. reactorHeat)
  setCursor(1, 4)
  io.write("Максимальная температура реактора: " .. maxReactorHeat)
  setCursor(1, 5)
  io.flush()

  --updateValues()
  -- Убрал функцию, т.к. не совсем корректно работала. Проще уже оставить так, как написанно выше.

  -- if reactorHeat and reactorActive then (ЭТО СТАРАЯ ВЕРСИЯ, НА ВСЯКИЙ СЛУЧАЙ)
  if reactorHeat then -- Нужна проверка температуры впринципе, иначе возникает проблема с nil
      -- Проверка на перегрев реактора
      if reactorHeat > 60 then
        deactivateReactor() -- Выключаем реактор при превышении температуры
        print("Реактор перегрелся!") -- Выводим сообщение
        running = false -- Остановка программы без выхода, чтобы пользователь не проебал вывод программы и понял что произошло
        --[[Важное уточнение, по поводу работы защиты от дебила!
            Если наш реактор достиг установленной температуры корпуса (По дефолту 60%), то программа останавливает реактор и выводит сообщение об этом.
            Но, если мы полный мудак и продолжим греть реактор после ошибки (Программа с шансом 50% даёт включить реактор),
            то далее программа не будет нас останавливать.
            Соответственно, чтобы предотвратить взрыв, то при срабатывании этой АЗ нужно:
            1) Не завершать программу
            2) Охладить реактор, либо он может остыть сам
            3) Запустить программу, при достижении температуры менее указанной]]
      end
    end

  -- Запрашиваем ввод пользователя, если он вообще есть
  local _, _, _, key = event.pull(0, "key_up")
  --os.sleep(1) (Не рекомендуется, иначе ввод клавиши проблемный)
  if key == 0x18 then
    activateReactor()    -- Включаем реактор при нажатии клавиши "O"
  elseif key == 0x2E then
    deactivateReactor()  -- Выключаем реактор при нажатии клавиши "C"
  elseif key == 0x10 then
	  clearScreen() -- Обязательно чистим экран, т.к. текст зависнет на экране
    running = false -- Выходим из программы при нажатии клавиши "Q"
  end

  -- Ждем 1 секунду перед следующей проверкой реактора (Не рекомендуется, иначе программа лагает)
  --os.sleep(1)
end