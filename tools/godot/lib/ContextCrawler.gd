# [GVRN]
class_name ContextCrawler

## Helper library for recursive file crawling.

static func find_files(path: String, ext: String, blacklist: Array[String]) -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	if not dir: return files
		
	dir.list_dir_begin()
	_crawl_directory(dir, path, ext, blacklist, files)
	return files

static func _crawl_directory(dir: DirAccess, path: String, ext: String, blacklist: Array[String], files: Array[String]) -> void:
	var file_name: String = dir.get_next()
	while file_name != "":
		_process_entry(path, file_name, ext, blacklist, files, dir)
		file_name = dir.get_next()

static func _process_entry(path: String, name: String, ext: String, blacklist: Array[String], files: Array[String], dir: DirAccess) -> void:
	if dir.current_is_dir():
		_handle_dir(path.path_join(name), name, ext, blacklist, files)
	else:
		_handle_file(path.path_join(name), name, ext, files)

static func _handle_dir(full_path: String, name: String, ext: String, blacklist: Array[String], files: Array[String]) -> void:
	if not name in blacklist and not name.begins_with("."):
		files.append_array(find_files(full_path, ext, blacklist))

static func _handle_file(full_path: String, name: String, ext: String, files: Array[String]) -> void:
	if name.ends_with(ext):
		files.append(full_path)
