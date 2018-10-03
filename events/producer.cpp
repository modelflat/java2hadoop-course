#include <iostream>
#include <iomanip>
#include <random>
#include <string>
#include <ctime>

#include "../fast-cpp-csv-parser/csv.h"

std::random_device device;
std::mt19937 twister {device()};


inline uint32_t makeIp() {
	static std::uniform_int_distribution<uint32_t> uniform { 0x01000000, 0xdfffffff };
	return uniform(twister);
}

inline float makePrice() {
	static std::normal_distribution<float> normal {25, 5};
	return std::abs(normal(twister));
}

int makeTimeSeconds() {
	static std::normal_distribution<float> seconds { 86400 / 2, 86400 / 6 };
	auto tm = seconds(twister);
	if (tm < 0 || tm > 86400) {
		return 86400 / 2;
	}
	return static_cast<int>(tm);
}

int makeDateDays() {
	static std::uniform_int_distribution<int> days { 0, 6 };
	return days(twister);
}

std::tm makeDateTime() {
	int days = makeDateDays() + 1;
	int seconds = makeTimeSeconds();
	int hours = seconds / 3600;
	int minutes = (seconds % 3600) / 60;
	int sec = (seconds % 3600) % 60;
	return std::tm { .tm_mday=days, .tm_sec=sec, .tm_min=minutes, .tm_hour=hours, .tm_year=118 };
}

struct Event {
	std::string name;
	float price;
	std::tm dateTime;
	union { uint32_t ip_n; unsigned char ip_c[4]; };
	std::string category;
};

struct TypeName {
	std::string type, name;
};

class TypeNameRegistry {
	std::vector<TypeName> registry_;
public:
	TypeNameRegistry(std::vector<TypeName>&& registry) : registry_(std::forward<std::vector<TypeName>>(registry)) 
	{}

	inline TypeName getRandom() const noexcept {
		static std::uniform_int_distribution<size_t> indexGen(0, registry_.size() - 1);
		return registry_[indexGen(twister)];
       	}
};

Event makeRandomEvent(const TypeNameRegistry& registry) {
	TypeName tn = registry.getRandom();
	return Event {
	       tn.name, makePrice(), makeDateTime(), { makeIp() }, tn.type 
       	};
}

std::ostream& operator<<(std::ostream& stream, const Event& event) {
#define SEP ','
	char timeString[64];
	strftime(timeString, sizeof(timeString), "%Y-%m-%d %H:%M:%S", &event.dateTime);
	stream << timeString << SEP;
	stream << (int)event.ip_c[0] << '.';
	stream << (int)event.ip_c[1] << '.';
	stream << (int)event.ip_c[2] << '.';
	stream << (int)event.ip_c[3];
	stream << SEP << event.category << SEP << event.name << SEP << std::setprecision(2) << event.price;
	return stream;
}

TypeNameRegistry loadTypesAndNames(const std::string& path) {
	io::CSVReader<2> reader {path};
	reader.read_header(io::ignore_extra_column, "type", "name");
	TypeName tn;
	std::vector<TypeName> allTypesAndNames;
	allTypesAndNames.reserve(1024);
	while (reader.read_row(tn.type, tn.name)) {
		allTypesAndNames.push_back(tn);
	}
	return TypeNameRegistry(std::move(allTypesAndNames));
}

int main(int argc, char* argv[]) {
	std::ios::sync_with_stdio(false);
	if (argc < 2) {
		std::cout << "usage: " << argv[0] << " <count or INF> [types and names csv]" <<  std::endl;
		return 0;
	}

	size_t count = 1;
	bool infinity = false;
	if (argc >= 2) {
		std::string countArg = argv[1];
		infinity = countArg == "INF";
		if (!infinity) {
			count = atol(countArg.c_str());
		}
	}

	std::string typesNamesFile = "TypesAndNames.csv";
	if (argc == 3) {
		typesNamesFile = argv[2];
	}
	
	auto typesAndNames = loadTypesAndNames(typesNamesFile);

	for (size_t i = 0; infinity || i < count; ++i) {
		std::cout << makeRandomEvent(typesAndNames) << std::endl;
	}
}
