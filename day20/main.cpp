#include <algorithm>
#include <deque>
#include <iostream>
#include <numeric>
#include <unordered_map>
#include <vector>

enum OpType {
  OUTPUT,
  CFLIP,
  NAND,
  BROADCAST,
};

struct Operation {
  OpType type = OUTPUT;
  std::vector<std::string> outputs = {};
  std::unordered_map<std::string, bool> state = {};
};

std::vector<std::string> StrSplit(const std::string& s,
                                  const std::string& delim) {
  std::vector<std::string> tokens;
  size_t start = 0;
  size_t end = s.find(delim);
  while (end != std::string::npos) {
    tokens.push_back(s.substr(start, end - start));
    start = end + delim.length();
    end = s.find(delim, start);
  }
  tokens.push_back(s.substr(start));
  return tokens;
}

std::unordered_map<std::string, Operation> parse_input() {
  std::unordered_map<std::string, Operation> operations;
  std::string line;
  while (std::getline(std::cin, line)) {
    auto parts = StrSplit(line, " -> ");
    auto label = parts[0];
    auto outputs = StrSplit(parts[1], ", ");

    OpType op_type;
    if (label[0] == '%') {
      op_type = CFLIP;
      label = label.substr(1);
    } else if (label[0] == '&') {
      op_type = NAND;
      label = label.substr(1);
    } else {
      op_type = BROADCAST;
    }

    operations[label] = Operation{op_type, outputs};
  }

  for (auto& [label, op] : operations) {
    for (const auto& output : op.outputs) {
      operations[output].state[label] = false;
    }
  }
  return operations;
}

void update(std::deque<std::tuple<std::string, std::string, bool>>& stack,
            Operation& op, const std::string& label, const std::string& last,
            bool signal) {
  switch (op.type) {
    case CFLIP: {
      if (!signal) {
        auto& s = op.state["self"];
        s = !s;
        for (const auto& output : op.outputs) {
          stack.push_back({label, output, s});
        }
      }
      break;
    }
    case NAND: {
      op.state[last] = signal;
      bool all_on = std::all_of(op.state.begin(), op.state.end(),
                                [](const auto& p) { return p.second; });
      for (const auto& output : op.outputs) {
        stack.push_back({label, output, !all_on});
      }
      break;
    }
    case BROADCAST: {
      for (const auto& output : op.outputs) {
        stack.push_back({label, output, false});
      }
      break;
    }
    case OUTPUT: {
      break;
    }
  }
}

int64_t part1(std::unordered_map<std::string, Operation> operations) {
  int64_t lows = 0;
  int64_t highs = 0;

  auto push = [&]() {
    std::deque<std::tuple<std::string, std::string, bool>> stack;
    stack.push_back({"button", "broadcaster", false});

    while (!stack.empty()) {
      auto [last, label, signal] = stack.front();
      stack.pop_front();

      if (signal)
        ++highs;
      else
        ++lows;
      auto& op = operations.at(label);
      update(stack, op, label, last, signal);
    }
  };

  for (int i = 0; i < 1000; push(), ++i);

  return lows * highs;
}

int64_t part2(std::unordered_map<std::string, Operation> operations) {
  auto parents = [](const Operation& op) {
    std::vector<std::string> p;
    for (const auto& [label, state] : op.state) {
      p.push_back(label);
    }
    return p;
  };

  std::string choke = parents(operations["rx"])[0];

  std::unordered_map<std::string, int> last_seen;
  std::unordered_map<std::string, int> periods;

  int64_t presses = 0;

  auto push = [&]() {
    std::deque<std::tuple<std::string, std::string, bool>> stack;
    stack.push_back({"button", "broadcaster", false});

    while (!stack.empty()) {
      auto [last, label, signal] = stack.front();
      stack.pop_front();

      if (label == choke && signal) {
        if (auto it = last_seen.find(last); it != last_seen.end()) {
          periods[last] = presses - it->second;
        }
        last_seen[last] = presses;
      }

      auto& op = operations.at(label);
      update(stack, op, label, last, signal);
    }
  };

  for (; periods.size() < 4; ++presses, push());

  int64_t lcm = 1;
  for (const auto& [label, period] : periods) {
    auto last = last_seen[label];
    if (last % period != 0) {
      std::cerr << "ERROR: " << label << " periods are not starting at 0"
                << std::endl;
      return -1;
    }
    lcm = std::lcm(lcm, int64_t(period));
  }
  return lcm;
}

int main() {
  auto operations = parse_input();
  std::cout << "Part 1: " << part1(operations) << "\n"
            << "Part 2: " << part2(operations) << "\n";
}
