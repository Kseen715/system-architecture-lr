#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>
#include <random>
#include <regex>
using namespace std;

const string lexems[] = {
    "auto", "break", "case", "char", "const", "continue", "default", "do", "double",
    "else", "enum", "extern", "float", "for", "goto", "if", "int", "long", "register",
    "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef",
    "union", "unsigned", "void", "volatile", "while", "asm", "bool", "catch", "class",
    "const_cast", "delete", "dynamic_cast", "explicit", "export", "false", "friend",
    "inline", "mutable", "namespace", "new", "operator", "private", "protected",
    "public", "reinterpret_cast", "static_cast", "template", "this", "throw", "true",
    "try", "typeid", "typename", "using", "virtual", "wchar_t", "alignas", "alignof",
    "char16_t", "char32_t", "constexpr", "decltype", "noexcept", "nullptr", "static_assert",
    "thread_local", "override", "final", "import", "module", "transaction_safe", "transaction_safe_dynamic",
    "atomic_cancel", "atomic_commit", "atomic_noexcept", "synchronized", "export", "module", "import",
    "concept", "requires", "co_await", "co_return", "co_yield", "reflexpr", "sizeof", "alignof", "typeid",
    "decltype", "static_assert", "noexcept", "template", "typename", "using", "export", "module", "import",
    "concept", "requires", "co_await", "co_return", "co_yield", "reflexpr", "sizeof", "alignof", "typeid",
    "decltype", "static_assert", "noexcept", "template", "typename", "using", "export", "module", "import",
    "concept", "requires", "co_await", "co_return", "co_yield", "reflexpr", "sizeof", "alignof", "typeid",
    "decltype", "static_assert", "noexcept", "template", "typename", "using", "export", "module", "import",
    "concept", "requires", "co_await", "co_return", "co_yield", "reflexpr", "sizeof", "alignof", "typeid", "iterator", "initializer_list", "other", "list", "size_t", "vector", "map", "set", "string", "regex", "random_device", "mt19937", "uniform_int_distribution", "sregex_iterator", "smatch", "endl", "cin", "std", "cout", "ifstream", "ofstream", "min", "max", "abs", "main"};

// Функция генерации случайного имени переменной заданной длины
string generateRandomName(int length)
{
    static const char alphanum[] = "O0oGgqQ";
    static const char start[] =
        "OooGgqQ";

    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> dis(0, sizeof(alphanum) - 2);

    stringstream ss;
    ss << start[dis(gen)];
    for (int i = 0; i < length; ++i)
    {
        ss << alphanum[dis(gen)];
    }
    return ss.str();
}

// Функция удаления комментариев из текста
string removeComments(const string &code)
{
    regex commentRegex("/\\*([^*]|(\\*+[^*/]))*\\*+/|//[^\\n]*");
    return regex_replace(code, commentRegex, "");
}

// Функция обфускации кода
string obfuscateCode(const string &code)
{
    map<string, string> variableMap;
    string result = removeComments(code);

    // Убираем все табуляции, переносы строк и заменяем множественные пробелы на одиночные
    result.erase(remove(result.begin(), result.end(), '\t'), result.end());
    result.erase(remove(result.begin(), result.end(), '\n'), result.end());
    regex spaceRegex("\\s+");
    result = regex_replace(result, spaceRegex, " ");

    // Регулярное выражение для поиска текста в кавычках
    regex stringRegex("\"(?:\\\\.|[^\"])*\"");

    // Находим все строки в кавычках и временно заменяем их временно
    string placeholder = "##STRING##";
    vector<string> stringsToPreserve;
    sregex_iterator stringIter(result.begin(), result.end(), stringRegex);
    sregex_iterator stringEnd;
    while (stringIter != stringEnd)
    {
        smatch match = *stringIter;
        stringsToPreserve.push_back(match.str());
        result.replace(match.position(), match.length(), placeholder);
        ++stringIter;
    }

    // Проводим обфускацию переменных
    regex variableRegex("(\\b(?:int|float|double|bool|char|string|auto)\\s+)(\\b(?!main\\b)\\w+)");
    sregex_iterator iter(result.begin(), result.end(), variableRegex);
    sregex_iterator end;

    while (iter != end)
    {
        smatch match = *iter;
        if (match.size() == 3)
        {
            string dataType = match[1];
            string varName = match[2];

            // Проверяем, что переменная не встречается внутри строк
            bool isInString = false;
            for (const auto &str : stringsToPreserve)
            {
                if (str.find(varName) != string::npos)
                {
                    isInString = true;
                    break;
                }
            }

            if (!isInString)
            {
                string newName = generateRandomName(32);
                variableMap[varName] = newName;

                regex replaceRegex("\\b" + dataType + varName + "\\b");
                result = regex_replace(result, replaceRegex, dataType + newName);
            }
        }
        ++iter;
    }

    // Восстанавливаем строки обратно в текст
    for (size_t i = 0; i < stringsToPreserve.size(); ++i)
    {
        size_t pos = result.find(placeholder);
        result.replace(pos, placeholder.length(), stringsToPreserve[i]);
    }

    for (const auto &pair : variableMap)
    {
        regex variableUsageRegex("\\b" + pair.first + "\\b");
        result = regex_replace(result, variableUsageRegex, pair.second);
    }

    return result;
}

int main()
{
    // Открываем файл .txt для чтения
    ifstream inputFile("input.cpp");
    if (!inputFile.is_open())
    {
        cout << "Cannot open input file!" << endl;
        return 1;
    }

    // Считываем содержимое файла в строку
    stringstream buffer;
    buffer << inputFile.rdbuf();
    string originalContent = buffer.str();
    inputFile.close();

    string toObfuscate = originalContent;
    // Убираем из toObfuscate все include define строки и using и помещаем их в отдельную строку
    string essentials;

    // Убираем все include строки <> ""
    regex includeRegex("#include\\s+[\"<][^\">]+[\">]");
    toObfuscate = regex_replace(toObfuscate, includeRegex, "");

    // Убираем все define строки
    regex defineRegex("#define\\s+\\w+(\\(.*\\))?\\s+.*");
    toObfuscate = regex_replace(toObfuscate, defineRegex, "");

    // Убираем все using строки
    regex usingRegex("using\\s+\\w+(::\\w+)*(<[^>]*>)?\\s*=\\s*\\w+(::\\w+)*(<[^>]*>)?;");
    toObfuscate = regex_replace(toObfuscate, usingRegex, "");

    // Находим все include строки и помещаем их в essentials
    sregex_iterator includeIter(originalContent.begin(), originalContent.end(), includeRegex);
    sregex_iterator includeEnd;

    while (includeIter != includeEnd)
    {
        smatch match = *includeIter;
        essentials += match.str() + "\n";
        ++includeIter;
    }

    // Находим все define строки и помещаем их в essentials
    sregex_iterator defineIter(originalContent.begin(), originalContent.end(), defineRegex);
    sregex_iterator defineEnd;

    while (defineIter != defineEnd)
    {
        smatch match = *defineIter;
        essentials += match.str() + "\n";
        ++defineIter;
    }

    // Находим все using строки и помещаем их в essentials
    sregex_iterator usingIter(originalContent.begin(), originalContent.end(), usingRegex);
    sregex_iterator usingEnd;

    while (usingIter != usingEnd)
    {
        smatch match = *usingIter;
        essentials += match.str() + "\n";
        ++usingIter;
    }

    auto lexemDict = map<string, string>();
    for (const auto &lexem : lexems)
    {
        lexemDict[lexem] = generateRandomName(32);
    }

    string llex;
    for (const auto &pair : lexemDict)
    {
        llex += "#define " + pair.second + " " + pair.first + "\n";
    }

    // Обфусцируем содержимое файла
    string obfuscated = obfuscateCode(toObfuscate);

    for (const auto &pair : lexemDict)
    {
        regex lexemRegex("\\b" + pair.first + "\\b");
        obfuscated = regex_replace(obfuscated, lexemRegex, pair.second);
    }

    obfuscated = obfuscated.substr(3);

    string obfuscatedContent = essentials + llex + obfuscated;

    // Открываем файл для записи обфусцированного содержимого
    ofstream outputFile("output.cpp");
    if (!outputFile.is_open())
    {
        cout << "Cannot open output file!" << endl;
        return 1;
    }

    // Записываем обфусцированное содержимое в файл
    outputFile << obfuscatedContent;
    outputFile.close();

    cout << "Obfuscation complete!" << endl;
    return 0;
}
