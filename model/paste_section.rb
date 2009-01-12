require "sourceclassifier"

class PasteSection
  SECTION_PREFIX = %r{^##\s+}
  SECTION_MARKER = %r{^(##\s+[/\w].*?)(?:\r?\n|$)}sm

  module SectionHelper
    def sections
      @section_title = title
      @sections ||= paste_body.to_s.split(PasteSection::SECTION_MARKER).map do |sec| 
        if sec_m = sec.match(PasteSection::SECTION_MARKER)
          @section_title = sec_m[1].sub(PasteSection::SECTION_PREFIX,'')
        end
        PasteSection.new(sec, syntax, @section_title) 
      end.reject { |n| n.to_s == "" }
    end
  end

end

class PasteSection
  attr_reader :syntax, :text, :title
  attr_accessor :uv_theme
  def initialize(string, syntax, title, uv_theme = 'iplastic')
    @syntax = syntax
    @text = string.to_s.rstrip.sub(/^[\r\n]+/,'')
    @title = title.to_s.rstrip
    @uv_theme = uv_theme
  end

  def to_s
    text.to_s
  end


  def highlighted
    if section_header?
      "<p class=\"section-title\">#{@title}</p>"
    else
      possible_file = File.basename(@title.split.last.chomp)
      if mime_map.keys.include?(ext = ("." + possible_file.split(".").last))
        @syntax = mime_map[ext]
      else
        classifier = SourceClassifier.new
        new_syntax = classifier.identify(text)
        if syntax_map.keys.include?(new_syntax)
          @syntax = syntax_map[new_syntax]
        end
      end
      highlight 
    end
  end

  def mime_types
    mime_map
  end
  private

  def highlight
    require "coderay" unless Object.const_defined?("CodeRay")
    require "uv" unless Object.const_defined?("Uv")
    if CodeRay::Scanners.list.include?(syntax)
      CodeRay.highlight(text, syntax.to_sym, :line_numbers => :table, :css => :class)
    else
      "<br />" + Uv.parse(text, "xhtml", syntax, true, uv_theme).sub("<span","\n<span")
    end
  end

  def section_header?
    text.include?(@title)
  end

  def syntax_map
    @syntax_map ||= {
      "Ruby" => "ruby",
      "Gcc" => "c"
    }
  end

  def mime_map
    return @h if @h.kind_of?(Hash)
    @h = Hash.new("plaintext").merge(
      {
        ".3gp" => "plaintext",
        ".a" => "plaintext",
        ".ai" => "plaintext",
        ".aif" => "plaintext",
        ".aiff" => "plaintext",
        ".asc" => "plaintext",
        ".asf" => "plaintext",
        ".asm" => "plaintext",
        ".asx" => "plaintext",
        ".atom" => "plaintext",
        ".au" => "plaintext",
        ".avi" => "plaintext",
        ".bat" => "plaintext",
        ".bin" => "plaintext",
        ".bmp" => "plaintext",
        ".bz2" => "plaintext",
        ".c" => "c",
        ".cab" => "plaintext",
        ".cc" => "c++",
        ".chm" => "plaintext",
        ".class" => "plaintext",
        ".com" => "plaintext",
        ".conf" => "plaintext",
        ".cpp" => "plaintext",
        ".crt" => "plaintext",
        ".css" => "css",
        ".csv" => "csv",
        ".cxx" => "c",
        ".deb" => "plaintext",
        ".der" => "plaintext",
        ".diff" => "diff",
        ".djv" => "plaintext",
        ".djvu" => "plaintext",
        ".dll" => "plaintext",
        ".dmg" => "plaintext",
        ".doc" => "plaintext",
        ".dot" => "plaintext",
        ".dtd" => "xml",
        ".dvi" => "plaintext",
        ".ear" => "plaintext",
        ".eml" => "plaintext",
        ".eps" => "ps",
        ".erb" => "rhtml",
        ".exe" => "plaintext",
        ".f" => "fortran",
        ".f77" => "fortran",
        ".f90" => "fortran",
        ".flv" => "plaintext",
        ".for" => "plaintext",
        ".gem" => "ruby",
        ".gemspec" => "ruby",
        ".gif" => "plaintext",
        ".gz" => "plaintext",
        ".h" => "c",
        ".haml" => "haml",
        ".hh" => "c++",
        ".htm" => "html",
        ".html" => "html",
        ".ico" => "plaintext",
        ".ics" => "plaintext",
        ".ifb" => "plaintext",
        ".iso" => "plaintext",
        ".jar" => "plaintext",
        ".java" => "java",
        ".jnlp" => "plaintext",
        ".jpeg" => "plaintext",
        ".jpg" => "plaintext",
        ".js" => "javascript",
        ".json" => "javascript",
        ".lisp" => "lisp",
        ".log" => "plaintext",
        ".m3u" => "plaintext",
        ".m4v" => "plaintext",
        ".man" => "plaintext",
        ".mathml" => "plaintext",
        ".mbox" => "plaintext",
        ".mdoc" => "plaintext",
        ".me" => "plaintext",
        ".mid" => "plaintext",
        ".midi" => "plaintext",
        ".mime" => "plaintext",
        ".mml" => "plaintext",
        ".mng" => "plaintext",
        ".mov" => "plaintext",
        ".mp3" => "plaintext",
        ".mp4" => "plaintext",
        ".mp4v" => "plaintext",
        ".mpeg" => "plaintext",
        ".mpg" => "plaintext",
        ".ms" => "plaintext",
        ".msi" => "plaintext",
        ".odp" => "plaintext",
        ".ods" => "plaintext",
        ".odt" => "plaintext",
        ".ogg" => "plaintext",
        ".p" => "plaintext",
        ".pas" => "plaintext",
        ".pbm" => "plaintext",
        ".pdf" => "plaintext",
        ".pem" => "plaintext",
        ".pgm" => "plaintext",
        ".pgp" => "plaintext",
        ".pkg" => "plaintext",
        ".pl" => "perl",
        ".pm" => "plaintext",
        ".png" => "plaintext",
        ".pnm" => "plaintext",
        ".ppm" => "plaintext",
        ".pps" => "plaintext",
        ".ppt" => "plaintext",
        ".ps" => "postscript",
        ".psd" => "plaintext",
        ".py" => "python",
        ".qt" => "plaintext",
        ".ra" => "plaintext",
        ".rake" => "ruby",
        ".ram" => "plaintext",
        ".rar" => "plaintext",
        ".rb" => "ruby",
        ".rdf" => "plaintext",
        ".rhtml" => "rhtml",
        ".roff" => "plaintext",
        ".rpm" => "plaintext",
        ".rss" => "xml",
        ".rtf" => "plaintext",
        ".ru" => "plaintext",
        ".s" => "plaintext",
        ".sgm" => "plaintext",
        ".sgml" => "plaintext",
        ".sh" => "shell-unix-generic",
        ".sig" => "plaintext",
        ".snd" => "plaintext",
        ".so" => "plaintext",
        ".svg" => "plaintext",
        ".svgz" => "plaintext",
        ".swf" => "plaintext",
        ".t" => "plaintext",
        ".tar" => "plaintext",
        ".task" => "ruby",
        ".tbz" => "plaintext",
        ".tcl" => "tcl",
        ".tex" => "tex",
        ".texi" => "latex",
        ".texinfo" => "tex",
        ".text" => "plaintext",
        ".tif" => "plaintext",
        ".tiff" => "plaintext",
        ".torrent" => "plaintext",
        ".tr" => "plaintext",
        ".txt" => "plaintext",
        ".vcf" => "plaintext",
        ".vcs" => "plaintext",
        ".vrml" => "plaintext",
        ".war" => "plaintext",
        ".wav" => "plaintext",
        ".wma" => "plaintext",
        ".wmv" => "plaintext",
        ".wmx" => "plaintext",
        ".wrl" => "plaintext",
        ".wsdl" => "plaintext",
        ".xbm" => "plaintext",
        ".xhtml" => "xhtml",
        ".xls" => "plaintext",
        ".xml" => "xml",
        ".xpm" => "plaintext",
        ".xsl" => "plaintext",
        ".xslt" => "plaintext",
        ".yaml" => "plaintext",
        ".yml" => "plaintext",
        ".zip" => "plaintext"
      }
    )
  end
end
