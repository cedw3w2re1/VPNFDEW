import telebot
import time
import logging
import datetime

# Замените на ваш API-ключ Telegram Bot
BOT_TOKEN = "7505591130:AAHXLTs2jCvv7jor5IVqrSNM95k7y5twwlc"

# Ссылка на бота, который выставляет счет
BILLING_BOT_LINK = "t.me/send?start=IV1nXjS2UqP7" 

bot = telebot.TeleBot(BOT_TOKEN)

# Ваш ID в Telegram, куда будут приходить уведомления
YOUR_ID = 1676055209  # Замените на ваш ID

# Словарь для хранения информации о платежах
payments = {}

logging.basicConfig(level=logging.DEBUG)  # Включите логирование

def get_price(duration, payment_method):
    if payment_method == "СБП":
        if duration == 1:
            return 50
        elif duration == 3:
            return 150
        elif duration == 6:
            return 250
        elif duration == 12:
            return 500
    elif payment_method == "Через бота":
        if duration == 1:
            return round(50 / 100, 2)
        elif duration == 3:
            return round(150 / 100, 2)
        elif duration == 6:
            return round(250 / 100, 2)
        elif duration == 12:
            return round(500 / 100, 2)
    return None  # Возвращаем None, если нет соответствующего варианта

@bot.message_handler(commands=['start'])
def start(message):
    bot.send_message(message.chat.id, "Привет! Я могу предоставить вам ссылку на VPN-подключение.")
    markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.row("Через бота", "Через СБП")
    bot.send_message(message.chat.id, "Оплата производится:", reply_markup=markup)  # Вернули кнопки
    bot.register_next_step_handler(message, handle_payment)

def handle_payment(message):
    if message.text == "Через бота":
        payment_method = "Через бота"
        bot.send_message(message.chat.id, f"Оплата через бота: {BILLING_BOT_LINK} ")
        bot.send_message(message.chat.id, "На какой период вы планируете купить подписку?")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("1 месяц", "3 месяца", "6 месяцев", "12 месяцев")
        bot.send_message(message.chat.id, "Выберите период:", reply_markup=markup)
        bot.register_next_step_handler(message, select_duration, payment_method=payment_method)
    elif message.text == "Через СБП":
        payment_method = "СБП"
        bot.send_message(message.chat.id, "На какой период вы планируете купить подписку?")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("1 месяц - 50 рублей", "3 месяца - 150 рублей", "6 месяцев - 250 рублей", "12 месяцев - 500 рублей")
        bot.send_message(message.chat.id, "Выберите период:", reply_markup=markup)
        bot.register_next_step_handler(message, select_duration, payment_method=payment_method)
    else:
        bot.send_message(message.chat.id, "Пожалуйста, выберите один из способов оплаты.")
        bot.register_next_step_handler(message, handle_payment)

def select_duration(message, payment_method):
    if payment_method == "СБП":
        if message.text == "1 месяц - 50 рублей":
            duration = 1
        elif message.text == "3 месяца - 150 рублей":
            duration = 3
        elif message.text == "6 месяцев - 250 рублей":
            duration = 6
        elif message.text == "12 месяцев - 500 рублей":
            duration = 12
        else:
            bot.send_message(message.chat.id, "Пожалуйста, выберите один из вариантов периода.")
            bot.register_next_step_handler(message, select_duration, payment_method=payment_method)
            return
        # Оплата через СБП
        price = get_price(duration, payment_method)
        bot.send_message(message.chat.id, f"Оплата через СБП: {price} рублей.")
        bot.send_message(message.chat.id, "Перейдите по ссылке для оплаты:")
        bot.send_message(message.chat.id, "https://www.sberbank.com/sms/pbpn?requisiteNumber=79501103700")  # Ваша ссылка СБП
        bot.send_message(message.chat.id, "После оплаты нажмите кнопку 'Оплатил'.")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Оплатил")
        bot.send_message(message.chat.id, "Ожидайте...", reply_markup=markup)
        bot.register_next_step_handler(message, confirm_payment, payment_method=payment_method, duration=duration)

    elif payment_method == "Через бота":
        if message.text == "1 месяц":
            duration = 1
        elif message.text == "3 месяца":
            duration = 3
        elif message.text == "6 месяцев":
            duration = 6
        elif message.text == "12 месяцев":
            duration = 12
        else:
            bot.send_message(message.chat.id, "Пожалуйста, выберите один из вариантов периода.")
            bot.register_next_step_handler(message, select_duration, payment_method=payment_method)
            return
        price = get_price(duration, payment_method)
        if price is not None:
            bot.send_message(message.chat.id, f"Стоимость подписки: {price} {payment_method == 'СБП' and 'рублей' or '$'}.")
            bot.send_message(message.chat.id, "После оплаты нажмите кнопку 'Оплатил'.")
            markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
            markup.row("Оплатил")
            bot.send_message(message.chat.id, "Ожидайте...", reply_markup=markup)
            bot.register_next_step_handler(message, confirm_payment, payment_method=payment_method, duration=duration)
        else:
            bot.send_message(message.chat.id, "Некорректный выбор периода. Пожалуйста, выберите один из вариантов.")
            bot.register_next_step_handler(message, select_duration, payment_method=payment_method)

def confirm_payment(message, payment_method, duration):
    if message.text == "Оплатил":
        payment_id = generate_payment_id(message.from_user.id)  # Используем message.from_user.id
        send_notification(message.from_user.id, message.from_user.username, payment_method, payment_id)  # Отправляем ID вам в личку
        payments[message.from_user.id] = {"status": "pending", "method": payment_method, "duration": duration, "subscription_start": datetime.datetime.now()}
        bot.send_message(message.chat.id, "Пока мы проверяем вашу оплату, скачайте приложение для VPN. На какую платформу будет установлен VPN?")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Android", "iOS")
        bot.send_message(message.chat.id, "Выберите платформу:", reply_markup=markup)
        bot.register_next_step_handler(message, send_app_link, payment_method=payment_method)
    else:
        bot.send_message(message.chat.id, "Пожалуйста, нажмите кнопку 'Оплатил' после оплаты.")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Оплатил")
        # Здесь нужно добавить  bot.register_next_step_handler
        bot.register_next_step_handler(message, confirm_payment, payment_method=payment_method, duration=duration)  # Не забываем про эту строку

def send_app_link(message, payment_method):
    payments[message.from_user.id]["platform"] = message.text  # Сохраняем платформу
    if message.text == "Android":
        bot.send_message(message.chat.id, "Play Market: https://play.google.com/store/apps/details?id=org.outline.android.client")
        bot.send_message(message.chat.id, "Ожидаем получения денег от вашего банка.  ")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Через бота", "Через СБП")
        bot.send_message(message.chat.id, "Ожидайте...", reply_markup=markup)  # Убираем старые кнопки, отправляем новое сообщение
    elif message.text == "iOS":
        bot.send_message(message.chat.id, "App Store: https://apps.apple.com/us/app/outline-app/id1356177741")
        bot.send_message(message.chat.id, "Ожидаем получения денег от вашего банка.  ")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Через бота", "Через СБП")
        bot.send_message(message.chat.id, "Ожидайте...", reply_markup=markup)  # Убираем старые кнопки, отправляем новое сообщение
    else:
        bot.send_message(message.chat.id, "Пожалуйста, выберите платформу: Android или iOS.")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Android", "iOS")
        bot.send_message(message.chat.id, "Выберите платформу:", reply_markup=markup)
        bot.register_next_step_handler(message, send_app_link, payment_method=payment_method)

def generate_payment_id(chat_id):
    # Упрощаем генерацию ID, используя только последние 4 цифры chat_id и секунды времени
    return f"{chat_id}_{int(time.time()) % 10000}"  # Ограничиваем секунды до 10000

def check_payment():
    # Замените этот метод на ваш реальный код проверки платежа,
    # используя API бота, который выставляет счет.
    # В этом примере мы просто возвращаем "success" или "failure"
    # в зависимости от  платежа.
    return "success" 

def send_notification(chat_id, username, payment_method, payment_id):
    bot.send_message(YOUR_ID, f"Пользователь @{username} (ID: {chat_id}) оплатил заказ с помощью {payment_method}. ID заказа: {payment_id}")

@bot.message_handler(commands=['o'])
def send_from(message):
    if message.from_user.id == YOUR_ID:  # Проверка на ваш ID
        payment_id = message.text.split()[1]  # Получаем ID заказа из сообщения
        logging.debug(f"Получен ID заказа: {payment_id}")
        chat_id = int(payment_id.split('_')[0])  # Извлекаем ID чата из payment_id
        if chat_id in payments and payments[chat_id]["status"] == "pending":
            payments[chat_id]["status"] = "success"
            send_vpn(message, payments[chat_id]["method"])  # Передаем message в send_vpn
        else:
            bot.send_message(message.chat.id, "Ошибка: платеж не найден или уже обработан.")
    else:
        bot.send_message(message.chat.id, "У вас нет прав на использование этой команды.")

def send_vpn(message, payment_method):  # Добавили message как параметр
    # Проверяем оплату, например, в вашем боте, который выставляет счет,
    # используя вебхуки или другие методы.
    payment_status = check_payment()
    if payment_status == "success":
        # Отправьте ссылку на VPN пользователю
        link = "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpBenlEZVQyWmNWVG1Na0d2QTk3bllR@130.0.232.35:44670/?outline=1"
        bot.send_message(
            chat_id=message.chat.id,
            text=f"Платеж успешен! Вы оплатили VPN-подключение. Вот ваша ссылка:  {link}  "
        )
        markup = telebot.types.InlineKeyboardMarkup()
        markup.add(telebot.types.InlineKeyboardButton("Купить подписку", callback_data="buy"),
                   telebot.types.InlineKeyboardButton("Мой профиль", callback_data="profile"))
        bot.send_message(message.chat.id, "Ожидайте...", reply_markup=markup)  # Убираем старые кнопки, отправляем новое сообщение
        bot.send_message(
            chat_id=YOUR_ID,  # Отправляем сообщение вам
            text=f"Информация о покупке: \nID пользователя: {message.from_user.id}\nПлатформа: {payments[message.from_user.id]['platform']}\nСрок подписки: {payments[message.from_user.id]['duration']} месяцев"
        )
        bot.register_next_step_handler(message, start)  # Бот готов к команде Мой профиль
    else:
        bot.send_message(YOUR_ID, "Ошибка платежа. Пожалуйста, проверьте номер платежа.")

@bot.callback_query_handler(func=lambda call: call.data == "profile")
def show_profile(call):
    if call.from_user.id in payments:
        user_data = payments[call.from_user.id]
        subscription_end = user_data.get("subscription_start", datetime.datetime.now()) + datetime.timedelta(days=30 * user_data.get("duration", 0))
        time_left = subscription_end - datetime.datetime.now()
        bot.send_message(call.message.chat.id, f"Ваш профиль:\n@{call.from_user.username}")  # Выводим @пользователя
        bot.send_message(call.message.chat.id, f"Активные подписки: {user_data.get('method', 'Нет данных')}")
        bot.send_message(call.message.chat.id, f"Срок подписки: {user_data.get('duration', 'Нет данных')} месяцев")
        bot.send_message(call.message.chat.id, f"Осталось: {time_left.days} дней, {time_left.seconds // 3600} часов")
        bot.send_message(call.message.chat.id, f"Ваша ссылка: ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpBenlEZVQyWmNWVG1Na0d2QTk3bllR@130.0.232.35:44670/?outline=1") # Замените на ссылку пользователя 
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Через бота", "Через СБП")
        bot.send_message(call.message.chat.id, "Ожидайте...", reply_markup=markup)  # Убираем старые кнопки, отправляем новое сообщение
        # bot.register_next_step_handler(message, show_profile) # Бот готов к команде Мой профиль
    else:
        bot.send_message(call.message.chat.id, "У вас нет активных подписок.")
        markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
        markup.row("Через бота", "Через СБП")
        bot.send_message(call.message.chat.id, "Ожидайте...", reply_markup=markup)  # Убираем старые кнопки, отправляем новое сообщение

@bot.callback_query_handler(func=lambda call: call.data == "buy")
def buy_subscription(call):
    bot.answer_callback_query(call.id)
    bot.send_message(call.message.chat.id, "Перенаправляю вас в начало...")
    bot.send_message(call.message.chat.id, "Привет! Я могу предоставить вам ссылку на VPN-подключение.")
    markup = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
    markup.row("Через бота", "Через СБП")
    bot.send_message(call.message.chat.id, "Оплата производится:", reply_markup=markup)
    bot.register_next_step_handler(call.message, handle_payment)


@bot.message_handler(commands=['restart'])
def restart_bot(message):
    if message.from_user.id in payments:
        bot.send_message(message.chat.id, "Перезапускаю бота...")
        time.sleep(1)  # Добавьте паузу для визуального эффекта
        start(message)  # Вызовите функцию start для перезапуска
    else:
        bot.send_message(message.chat.id, "У вас нет прав на использование этой команды.")

bot.polling()
    
