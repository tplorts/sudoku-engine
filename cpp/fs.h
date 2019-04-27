#if !defined(FS_H)
#define FS_H

#include <regex>
#include <string>
#include <vector>

std::vector<std::string> read_directory(const std::string& directory_path,
                                        const std::regex& name_regex);

#endif // FS_H
