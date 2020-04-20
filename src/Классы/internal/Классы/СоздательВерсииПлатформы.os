#Использовать 1commands

Перем Версия;
Перем Разрядность;
Перем КаталогВерсии;
Перем УчебнаяВерсия;

Перем ПутьКПредприятию;
Перем ПутьКТонкомуКлиенту;
Перем ПутьКRAC;
Перем ПутьКDBGS;

Перем ИмяФайлаПредприятия;
Перем ИмяФайлаТонкийКлиент;
Перем ИмяФайлаУчебнаяВерсия;
Перем ИмяФайлаRAC;
Перем ИмяФайлаDBGS;

Перем ЭтоWindows;
Перем Лог;

// Устанавливает версию 
//
// Параметры:
//   ПВерсия - Строка - номер версии в формате 8.3.13.1341
//
Процедура УстановитьВерсию(Знач ПВерсия) Экспорт
	Версия = ПВерсия;
КонецПроцедуры

// Устанавливает каталог версии 
//
// Параметры:
//   ПКаталогВерсии - Строка - путь к каталогу версии
//
Процедура УстановитьКаталогВерсии(Знач ПКаталогВерсии) Экспорт
	КаталогВерсии = ПКаталогВерсии;
КонецПроцедуры

// Устанавливает разрядность
//
// Параметры:
//   ПРазрядность - Строка, Неопределено - разрядность требуемой версии (перечисление из РазрядностьПлатформы)
//										* РазрядностьПлатформы.x86
//										* РазрядностьПлатформы.x64
//
Процедура УстановитьРазрядность(Знач ПРазрядность) Экспорт
	Разрядность = ПРазрядность;
КонецПроцедуры

// Выполняет поиск исполняемых файлов платформы 1С
//
//  Возвращаемое значение:
//   Булево - признак успешности поиска, ложь - если ничего не найдена
//
Функция НайтиПриложенияПлатформы() Экспорт

	ПутьКПредприятию = ПолучитьПутьКФайлу(ИмяФайлаПредприятия);
	
	Если НЕ ЗначениеЗаполнено(ПутьКПредприятию) Тогда
		ПутьКПредприятию = ПолучитьПутьКФайлу(ИмяФайлаУчебнаяВерсия);	
		УчебнаяВерсия = Истина;
	КонецЕсли;
	
	ПутьКТонкомуКлиенту = ПолучитьПутьКФайлу(ИмяФайлаТонкийКлиент);
	ПутьКRAC = ПолучитьПутьКФайлу(ИмяФайлаRAC);
	ПутьКDBGS = ПолучитьПутьКФайлу(ИмяФайлаDBGS);

	Если ОбщиеФункцииПлатформы.ЭтоНеопределеннаяВерсия(Версия) 
		И Не ЭтоWindows Тогда
		Версия = ОпределитьВерсиюПоRac(Версия);
	КонецЕсли;

	Возврат ЗначениеЗаполнено(ПутьКПредприятию)
		ИЛИ ЗначениеЗаполнено(ПутьКТонкомуКлиенту)
		ИЛИ ЗначениеЗаполнено(ПутьКRAC)
		ИЛИ ЗначениеЗаполнено(ПутьКDBGS);

КонецФункции

// Создает объект ВерсияПлатформы
//
// Возвращаемое значение:
//   Объект - созданный объект класса <ВерсияПлатформы>
//
Функция Создать() Экспорт

	ВерсияПлатформы = Новый ВерсияПлатформы(Версия, Разрядность, 
											КаталогВерсии, ПутьКПредприятию,
											ПутьКТонкомуКлиенту, ПутьКRAC, ПутьКDBGS, УчебнаяВерсия);

	Возврат ВерсияПлатформы;

КонецФункции

Функция ПолучитьПутьКФайлу(Знач ИмяФайла)
	
	Если ЭтоWindows Тогда
		ПутьКФайлу = ОбъединитьПути(КаталогВерсии, "bin", ИмяФайла);
	Иначе
		ПутьКФайлу = ОбъединитьПути(КаталогВерсии, ИмяФайла);
	КонецЕсли;

	Файл = Новый Файл(ПутьКФайлу);

	Если Файл.Существует() Тогда
		Возврат Файл.ПолноеИмя;
	КонецЕсли;
	
	Возврат "";

КонецФункции

Функция ОпределитьВерсиюПоRac(Знач УстановленнаяВерсия)

	мВерсияПлатформы = УстановленнаяВерсия;

	Если Не ЗначениеЗаполнено(ПутьКRAC) Тогда
		Возврат мВерсияПлатформы;
	КонецЕсли;

	Лог.Отладка("Определяю версию по утилите rac");

	Команда = Новый Команда;
	СтрокаЗапуска = ПутьКRAC + " -v ";
	Команда.УстановитьСтрокуЗапуска(СтрокаЗапуска);
	Команда.УстановитьПравильныйКодВозврата(0);
	Попытка
		Команда.Исполнить();
		мВерсияПлатформы = СокрЛП(Команда.ПолучитьВывод());
		Лог.Отладка("Определена версия <%1>", мВерсияПлатформы);

	Исключение		
		Лог.Отладка("Не удалось определить версию по утилите rac");
	КонецПопытки;

	Возврат мВерсияПлатформы;

КонецФункции

Процедура ПриСозданииОбъекта()
	
	Лог = Логирование.ПолучитьЛог("oscript.lib.v8find");

	СИ = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СИ.ВерсияОС), "windows") > 0;

	ИмяФайлаПредприятия = ПриложенияПлатформы.Предприятие;
	ИмяФайлаУчебнаяВерсия = ИмяФайлаПредприятия + "t";
	ИмяФайлаТонкийКлиент = ПриложенияПлатформы.ТонкийКлиент;
	ИмяФайлаRAC = ПриложенияПлатформы.RAC;
	ИмяФайлаDBGS = ПриложенияПлатформы.DBGS;

	Если ЭтоWindows Тогда
				
		ШаблонДляWindows = "%1.exe";

		ИмяФайлаПредприятия = СтрШаблон(ШаблонДляWindows, ИмяФайлаПредприятия);
		ИмяФайлаУчебнаяВерсия = СтрШаблон(ШаблонДляWindows, ИмяФайлаУчебнаяВерсия);
		ИмяФайлаТонкийКлиент = СтрШаблон(ШаблонДляWindows, ИмяФайлаТонкийКлиент);
		ИмяФайлаRAC = СтрШаблон(ШаблонДляWindows, ИмяФайлаRAC);
		ИмяФайлаDBGS = СтрШаблон(ШаблонДляWindows, ИмяФайлаDBGS);

	КонецЕсли;

	УчебнаяВерсия = Ложь;

КонецПроцедуры