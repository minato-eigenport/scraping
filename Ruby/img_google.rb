require "rubygems"
require "nokogiri"
require "open-uri"
require "cgi"
require "kconv"

$page_num=1;
$next = Array.new();
$result = Array.new();
$res_link= Array.new();


#検索文字を入力
#リクエストクエリに入力
#件数や絞り込みフィルタなどを取得
#次へを取得
def in_keyword()
	puts("")
	print "Input the Keyword for Search:"
	$keyword = gets.chop
	$keyword = $keyword.toutf8
	if $keyword=="" then
		in_keyword();
	end
	puts("")
	print "Start page:"
	$start = gets.chop
	puts("")
	print "End page:"
	$end = gets.chop
	puts("")
	print "Mode(0:normal 1:past month):"
	$mode = gets.chop
	$escaped_keyword = CGI.escape($keyword)
	# 検索結果を開く
	i_search($start,$end,$mode);
end

def i_search(start, ender, mode)
	i=start.to_i
	while i <= ender.to_i do
		url = "http://www.bing.com/images/search?sp=-1&pq=%u30d0%u30ec%u30a8&sc=4-3&sk=&cvid=4C0429E9B72946A5910BC22708B3CDFC&q=#{$escaped_keyword}&qft=+filterui:imagesize-wallpaper&FORM=R5IR4"
		if mode.to_i == 1
			url = "http://www.bing.com/images/search?sp=-1&pq=%u30d0%u30ec%u30a8&sc=4-3&sk=&cvid=4C0429E9B72946A5910BC22708B3CDFC&q=#{$escaped_keyword}&qft=+filterui:imagesize-wallpaper+filterui:age-lt43200&FORM=R5IR4"
		end
		url = url + "&first=" + ((i-1)*29).to_s
		
		$doc = Nokogiri.HTML(open(url))
		j=0
		$doc.css('div.item > a').each do |a|
			$result[j]=a[:href]
			puts $result[j]
			save_image($result[j]);
			j=j+1;
		end
		p j
		File.open("sample1.txt", "w") do |f| 
	  		f.puts($doc)
		end
	i=i+1
	end
	p "i="+i.to_s
end



##画像の保存
#パスを通す
#フォルダの確認
#保存
def save_image(url)
  #ディレクトリの作成
  dn = DateTime.now
  dt = dn.year.to_s + dn.mon.to_s + dn.day.to_s + "\\"
  dirName = "\img\\" + dt
  FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)


  #?などを含む名前はファイルにつけられないので変更、また同名のファイルがある場合は変更
  fileName = File.basename(url)
  filePath = dirName + fileName
  if fileName.include?('?')
  	dn = DateTime.now
  	fileName='img' + dn.hour.to_s + 'h' + dn.min.to_s + 'm' + dn.sec.to_s + 's' + '.jpg'
  end

  if File.exist?(filePath)
  	dn = DateTime.now
  	fileName='img' + dn.hour.to_s + 'h' + dn.min.to_s + 'm' + dn.sec.to_s + 's' + '.jpg'
  end
  filePath = dirName + fileName
  
  p filePath

  # write image adata
  open(filePath, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
    end
  end
end

#検索結果の表示
def p_result()
	puts("")
	print("Search for ",$keyword,"\t\t")
	puts($number)
	for i in 0..$res_link.length-1	
		print("[",i,"]\t: ",$result[i])
		puts("")
	end
	puts("")
	print("[b]: BackPage\t[n]: NextPage\t[s]: SearchAnother\t")
	puts("")
	print("[h]: PastHour\t[d]: PastDay\t[w]: PastWeek\t[m]: PastMonth\t")
	puts("")
	print("[i]: Image\t")
	puts("")
	print("[x]: Close")
	puts("")
	puts("")
end

#次の操作の入力を受け付ける
def in_next()
	print "So What?:"
	String val = gets.chop	
	puts("")
	case val
		when "b" then
			if $page_num==1 then
				puts("There are no pages back")
			elsif $page_num==2 then
				$page_num=$page_num-1
				$doc = Nokogiri.HTML(open("#{$next[$page_num]}"))
				read_result();
				clear_result();
			else
				$page_num=$page_num-1
				$doc = Nokogiri.HTML(open("http://www.google.co.jp#{$next[$page_num]}"))
				read_result();
				clear_result();
			end
		when "n" then
			if $page_num==$max_num-1 then
				puts("Sorry, can't show the next page")
			else
				$page_num=$page_num+1;
				$doc = Nokogiri.HTML(open("http://www.google.co.jp#{$next[$page_num]}"))
				puts "http://www.google.co.jp#{$next[$page_num]}"
				read_result();
				clear_result();
			end
		when "h" then
				$page_num=1;
				puts("In past hour")
				$doc = Nokogiri.HTML(open("http://www.google.co.jp#{$hour}"))
				read_result();
				clear_result();
		when "d" then
				$page_num=1;
				puts("In past day")
				$doc = Nokogiri.HTML(open("http://www.google.co.jp#{$day}"))
				read_result();
				clear_result();
		when "w" then
				$page_num=1;
				puts(" In past week")
				$doc = Nokogiri.HTML(open("http://www.google.co.jp#{$week}"))
				read_result();
				clear_result();
		when "m" then
				$page_num=1;
				puts("In past month")
				$doc = Nokogiri.HTML(open("http://www.google.co.jp#{$month}"))
				read_result();
				clear_result();
		when "s" then
				google();
		when "i" then
				#image_search();
				exit!
		when "x" then
				exit!
	end
	p_result();
	in_next();
end

def google()
	#文字列の入力と各種データの取得
	in_keyword();
	#検索結果の取得
	read_result();
	#検索結果の整理
	clear_result();
	#検索結果の表示
	p_result();
	#次の操作待ち
	in_next();
end