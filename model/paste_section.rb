require "sourceclassifier"

class PasteSection
  SECTION_PREFIX = %r{^##\s+}
  SECTION_MARKER = %r{^(##\s+[/\w].*?)(?:\r?\n|$)}sm

  # Map to match whole filenames
  STATIC_MAP = Hash.new("plaintext").merge({ # {{{
    "lighttpd.conf" => "lighttpd"
  }) # }}}

  # Map for SourceClassifier types
  SYNTAX_MAP = Hash.new("plaintext").merge({ #{{{
    "Ruby" => "ruby",
    "Gcc" => "c"
  }) # }}}

  # MimeTypes map
  MIME_MAP = Hash.new("plaintext").merge({ # {{{
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
    ".xhtml" => "nitro_xhtml",
    ".xls" => "plaintext",
    ".xml" => "xml",
    ".xpm" => "plaintext",
    ".xsl" => "plaintext",
    ".xslt" => "plaintext",
    ".yaml" => "plaintext",
    ".yml" => "plaintext",
    ".zip" => "plaintext"
  }) # }}}

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
    @title = title.to_s.rstrip
    @text = string.to_s.rstrip.sub(/^[\r\n]+/,'')
    @uv_theme = uv_theme
    @syntax = check_syntax(syntax)
    Ramaze::Log.warn("Syntax is #{@syntax.inspect}")
  end

  def highlighted
    if section_header?
      "<p class=\"section-title\">#{@title}</p>"
    else
      highlight 
    end
  end

  def to_s
    text.to_s
  end

  private

  def check_syntax(given_syntax)
    _syntax = nil
    possible_file = File.basename(@title.split.last.to_s.chomp)
    if STATIC_MAP.keys.include?(possible_file)
      _syntax = STATIC_MAP[possible_file]
    elsif MIME_MAP.keys.include?(ext = ("." + possible_file.split(".").last))
      _syntax = MIME_MAP[ext]
    else
      classifier = SourceClassifier.new
      new_syntax = classifier.identify(text)
      if SYNTAX_MAP.keys.include?(new_syntax)
        _syntax = SYNTAX_MAP[new_syntax]
      end
    end unless possible_file.blank?
    _syntax || given_syntax
  end

  def highlight
    require "coderay" unless Object.const_defined?("CodeRay")
    require "uv" unless Object.const_defined?("Uv")
    if CodeRay::Scanners.list.include?(syntax)
      CodeRay.highlight(text.to_s, syntax.to_sym, :line_numbers => :table, :css => :class)
    else
      "<br />" + Uv.parse(text, "xhtml", syntax, true, uv_theme).sub("<span","\n<span")
    end
  end

  def section_header?
    text.sub(SECTION_PREFIX, '') == @title
  end

end
