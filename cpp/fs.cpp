#include <dirent.h>
#include <regex>
#include <string>
#include <vector>

using namespace std;

vector<string> read_directory(const string& directory_path,
                              const regex& name_regex) {
  vector<string> paths;
  DIR* dir;
  struct dirent* entry;

  if ((dir = opendir(directory_path.c_str())) != NULL) {
    while ((entry = readdir(dir)) != NULL) {
      string entry_name(entry->d_name);

      if (regex_match(entry_name, name_regex)) {
        paths.push_back(entry_name);
      }
    }

    closedir(dir);
  }

  return paths;
}
