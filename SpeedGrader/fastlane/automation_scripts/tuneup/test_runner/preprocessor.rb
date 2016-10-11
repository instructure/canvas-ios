class Preprocessor
  def self.process(file)
    self.process_imports(file, [])
  end
  
private
  IMPORT_STATEMENT = /#import "([^"]+)"/
  def self.process_imports(file, imported_file_names)
    content = File.read(file)
    content.gsub(IMPORT_STATEMENT) do
      next if imported_file_names.include? $1
      
      imported_file_names << $1
      import_file = File.join(File.dirname(file), $1)
      begin
        "// begin #{File.basename($1)}" << "\n" << 
        process_imports(import_file, imported_file_names) << "\n" <<
        "// end #{File.basename($1)}" << "\n"
      rescue Exception => e
        STDERR.puts "Unable to process file #{import_file}: #{e}"
        $&
      end
    end
  end
end
