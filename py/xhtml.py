import xml.etree.ElementTree as ET #ET is standard shortening apparently
from html.parser import HTMLParser

SE=ET.SubElement #shorter aliasing
found_list=False #is the list with specific ID found yet, avoid dupes

#base should come from a file but doesn't matter,should be valid xhtml
base=ET.fromstring("""
<html>
<body>
<ul><li>unrelated list, lol</li></ul>
<ul id="my-list">
<li>first item</li>
<li>second item</li>
<li><a href="https://exampläüe.com" id="some_id">example link</a></li>

</ul>

<ul id="my-list">
<li>this list won't get stuff appended despite having same ID!</li>
</ul>
</body>
<br/>
</html>
""")

output=base
url="https://ww.ee?a=6&b=3&&&öü<"

for i in output.iter():
	if(found_list!=True):
		if(i.tag == "ul" and i.get("id")=="my-list"):
			SE(SE(i,"li"),"a").text=url
			#can't set href cause it's forcefully escaped
			found_list=True
			break
		if(found_list): break
o=ET.tostring(output,encoding="unicode",method="html")

print(o)


class MyHTMLParser(HTMLParser):
	global found_target_id
	global found_target_id_ever
	global closing_tags_needed
	global target
	global last_tag
	global last_tag_attrs
	found_target_id=False
	found_target_id_ever=False
	target="" #target ID
	last_tag="" #last seen tag
	last_tag_attrs=""
	
	try:
		if(found_target_id==found_target_id): True
	except NameError: found_target_id=False
	try:
		if(closing_tags_needed): True
	except NameError: closing_tags_needed=0
	try:
		if(target): True
	except NameError: target=""

	def handle_starttag(self, tag, attrs):
		global closing_tags_needed
		global found_target_id
		global found_target_id_ever
		global last_tag
		global last_tag_attrs
		global indent_width
		last_tag=tag
		last_tag_attrs=attrs
		indent_width=4
		#print("Encountered a start tag:", tag, "with attrs" if attrs else "", attrs if attrs else "")

		this_tag_attrs=""
		if last_tag=="a":
			#last_tag_attrs+=[("href",url)]
			for i in last_tag_attrs:
				if i[0]!="href":
					this_tag_attrs+=" "+i[0]+"="+i[1]
			this_tag_attrs+=f" href=\"{url}\""
			print(" "*closing_tags_needed*indent_width,"< "+tag+(this_tag_attrs if this_tag_attrs else "")+">")

		if found_target_id:
			closing_tags_needed+=1
			#print()
			#print("needs",closing_tags_needed,"closing tags")
			if tag != "a": print(" "*(closing_tags_needed-1)*indent_width,"< "+tag+">",attrs if attrs else "")
		if found_target_id==False and found_target_id_ever==False:
			for i in attrs:
				if i[0]=="id" and i[1]==target:
					print("TARGET FOUND",f"<{tag} {attrs}>")
					#print(tag,attrs)
					found_target_id=True
					found_target_id_ever=True
					break

	def handle_endtag(self, tag):
		global closing_tags_needed
		global found_target_id
		#print("Encountered an end tag :", tag)
		if found_target_id and closing_tags_needed <= 0:
			found_target_id=False
		if found_target_id and closing_tags_needed > 0:
			closing_tags_needed-=1
			print(" "*closing_tags_needed*indent_width,"</"+tag+">")
			#if found_target_id and closing_tags_needed > 0:
				#print(closing_tags_needed,"more",("tags" if closing_tags_needed>1 else "tag")+" to close")
				#print() 
			#else: print()

	def handle_data(self, data):
		global closing_tags_needed
		global found_target_id
		global indent_width
		#print("Encountered some data  :", data)
		if found_target_id and closing_tags_needed > 0: print(" "*closing_tags_needed*indent_width,data)

target="my-list"
parser=MyHTMLParser()
parser.feed(o)
parser.close() #unnecessary
