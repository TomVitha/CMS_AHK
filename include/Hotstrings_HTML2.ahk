#Hotstring EndChars `t          ; * Tab is now the only ending character - must be typed after the abbreviation to trigger
#Hotstring c1                   ; * Make all hotstrings below this point case-sensitive.

; * O: Omit the ending character of auto-replace hotstrings when the replacement is produced.
:o:a::<a></a>{left 4}
:o:abbr::<abbr></abbr>{left 7}
; :o:acronym::<acronym></acronym>{left 10}
:o:address::<address></address>{left 9}
:o:area::<area>{left 0}
:o:article::<article></article>{left 9}
:o:aside::<aside></aside>{left 8}
:o:audio::<audio></audio>{left 8}
:o:b::<b></b>{left 4}
:o:base::<base>{left 0}
:o:bdi::<bdi></bdi>{left 6}
:o:bdo::<bdo></bdo>{left 6}
; :o:big::<big></big>{left 6}
:o:blockquote::<blockquote></blockquote>{left 13}
:o:body::<body></body>{left 7}
:o:br::<br>{left 0}
:o:button::<button></button>{left 9}
:o:canvas::<canvas></canvas>{left 9}
:o:caption::<caption></caption>{left 9}
:o:center::<center></center>{left 9}
:o:cite::<cite></cite>{left 7}
:o:code::<code></code>{left 7}
:o:col::<col>{left 0}
:o:colgroup::<colgroup></colgroup>{left 11}
:o:data::<data></data>{left 7}
:o:datalist::<datalist></datalist>{left 11}
:o:dd::<dd></dd>{left 5}
; :o:del::<del></del>{left 6}
:o:details::<details></details>{left 9}
; :o:dfn::<dfn></dfn>{left 6}
:o:dialog::<dialog></dialog>{left 9}
; :o:dir::<dir></dir>{left 6}
:o:div::<div></div>{left 6}
:o:dl::<dl></dl>{left 5}
:o:dt::<dt></dt>{left 5}
:o:em::<em></em>{left 5}
:o:embed::<embed></embed>{left 9}
; :o:fencedframe::<fencedframe></fencedframe>{left 13}
:o:fieldset::<fieldset></fieldset>{left 11}
:o:figcaption::<figcaption></figcaption>{left 13}
:o:figure::<figure></figure>{left 9}
; :o:font::<font></font>{left 7}
:o:footer::<footer></footer>{left 9}
:o:form::<form></form>{left 7}
; :o:frame::<frame></frame>{left 7}
; :o:frameset::<frameset></frameset>{left 11}
:o:h1::<h1></h1>{left 5}
:o:h2::<h2></h2>{left 5}
:o:h3::<h3></h3>{left 5}
:o:h4::<h4></h4>{left 5}
:o:h5::<h5></h5>{left 5}
:o:h6::<h6></h6>{left 5}
:o:head::<head></head>{left 7}
:o:header::<header></header>{left 9}
:o:hgroup::<hgroup></hgroup>{left 9}
:o:hr::<hr>{left 0}
:o:html::<html></html>{left 7}
:o:i::<i></i>{left 4}
:o:iframe::<iframe></iframe>{left 9}
:o:img::<img>{left 0}
:o:input::<input>{left 0}
; :o:ins::<ins></ins>{left 6}
; :o:kbd::<kbd></kbd>{left 6}
:o:label::<label></label>{left 8}
:o:legend::<legend></legend>{left 9}
:o:li::<li></li>{left 5}
:o:link::<link>{left 0}
:o:main::<main></main>{left 7}
:o:map::<map></map>{left 7}
:o:mark::<mark></mark>{left 7}
; :o:marquee::<marquee></marquee>{left 11}
:o:menu::<menu></menu>{left 7}
:o:meta::<meta>{left 0}
; :o:meter::<meter></meter>{left 9}
:o:nav::<nav></nav>{left 7}
:o:nav::<nav></nav>{left 7}
; :o:nobr::<nobr></nobr>{left 7}
; :o:noembed::<noembed></noembed>{left 11}
; :o:noframes::<noframes></noframes>{left 11}
:o:noscript::<noscript></noscript>{left 11}
:o:object::<object></object>{left 9}
:o:ol::<ol></ol>{left 5}
:o:optgroup::<optgroup></optgroup>{left 11}
:o:option::<option></option>{left 9}
:o:output::<output></output>{left 9}
:o:p::<p></p>{left 4}
; :o:param::<param>{left 0}
:o:picture::<picture></picture>{left 11}
; :o:plaintext::<plaintext></plaintext>{left 11}
:o:portal::<portal></portal>{left 9}
:o:pre::<pre></pre>{left 6}
:o:progress::<progress></progress>{left 11}
; :o:q::<q></q>{left 5}
; :o:rb::<rb></rb>{left 5}
; :o:rp::<rp></rp>{left 5}
; :o:rt::<rt></rt>{left 5}
; :o:rtc::<rtc></rtc>{left 6}
; :o:ruby::<ruby></ruby>{left 7}
; :o:s::<s></s>{left 4}
; :o:samp::<samp></samp>{left 7}
:o:script::<script></script>{left 9}
; :o:search::<search></search>{left 9}
:o:section::<section></section>{left 11}
:o:select::<select></select>{left 9}
:o:slot::<slot></slot>{left 7}
:o:small::<small></small>{left 7}
:o:source::<source></source>{left 9}
:o:span::<span></span>{left 7}
:o:strike::<strike></strike>{left 9}
:o:strong::<strong></strong>{left 9}
:o:style::<style></style>{left 8}
:o:sub::<sub></sub>{left 5}
:o:summary::<summary></summary>{left 9}
:o:sup::<sup></sup>{left 5}
:o:table::<table></table>{left 9}
:o:tbody::<tbody></tbody>{left 9}
:o:td::<td></td>{left 5}
:o:template::<template></template>{left 11}
:o:textarea::<textarea></textarea>{left 11}
:o:tfoot::<tfoot></tfoot>{left 9}
:o:th::<th></th>{left 5}
:o:thead::<thead></thead>{left 9}
:o:time::<time></time>{left 7}
:o:title::<title></title>{left 9}
:o:tr::<tr></tr>{left 5}
:o:track::<track></track>{left 9}
; :o:tt::<tt></tt>{left 5}
; :o:u::<u></u>{left 4}
:o:ul::<ul></ul>{left 5}
:o:var::<var></var>{left 7}
:o:video::<video></video>{left 9}
:o:wbr::<wbr>{left 0}
; :o:xmp::<xmp></xmp>{left 7}