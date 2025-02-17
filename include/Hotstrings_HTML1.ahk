#Hotstring EndChars             ; * No ending character - must be typed after the abbreviation to trigger
#Hotstring c1                   ; * Make all hotstrings below this point case-sensitive.

; * B0: Automatic backspacing is NOT done to erase the abbreviation you type.
:*b0:<a>::</a>{left 4}
:*b0:<abbr>::</abbr>{left 7}
:*b0:<acronym>::</acronym>{left 10}
:*b0:<address>::</address>{left 9}
; :*b0:<area>::{left 0}
:*b0:<article>::</article>{left 9}
:*b0:<aside>::</aside>{left 8}
:*b0:<audio>::</audio>{left 8}
:*b0:<b>::</b>{left 4}
; :*b0:<base>::{left 0}
:*b0:<bdi>::</bdi>{left 6}
:*b0:<bdo>::</bdo>{left 6}
; :*b0:<big>::</big>{left 6}
:*b0:<blockquote>::</blockquote>{left 13}
:*b0:<body>::</body>{left 7}
; :*b0:<br>::{left 0}
:*b0:<button>::</button>{left 9}
:*b0:<canvas>::</canvas>{left 9}
:*b0:<caption>::</caption>{left 9}
:*b0:<center>::</center>{left 9}
:*b0:<cite>::</cite>{left 7}
:*b0:<code>::</code>{left 7}
; :*b0:<col>::{left 0}
:*b0:<colgroup>::</colgroup>{left 11}
:*b0:<data>::</data>{left 7}
:*b0:<datalist>::</datalist>{left 11}
:*b0:<dd>::</dd>{left 5}
; :*b0:<del>::</del>{left 6}
:*b0:<details>::</details>{left 9}
; :*b0:<dfn>::</dfn>{left 6}
:*b0:<dialog>::</dialog>{left 9}
; :*b0:<dir>::</dir>{left 6}
:*b0:<div>::</div>{left 6}
:*b0:<dl>::</dl>{left 5}
:*b0:<dt>::</dt>{left 5}
:*b0:<em>::</em>{left 5}
:*b0:<embed>::</embed>{left 9}
; :*b0:<fencedframe>::</fencedframe>{left 13}
:*b0:<fieldset>::</fieldset>{left 11}
:*b0:<figcaption>::</figcaption>{left 13}
:*b0:<figure>::</figure>{left 9}
; :*b0:<font>::</font>{left 7}
:*b0:<footer>::</footer>{left 9}
:*b0:<form>::</form>{left 7}
; :*b0:<frame>::</frame>{left 7}
; :*b0:<frameset>::</frameset>{left 11}
:*b0:<h1>::</h1>{left 5}
:*b0:<h2>::</h2>{left 5}
:*b0:<h3>::</h3>{left 5}
:*b0:<h4>::</h4>{left 5}
:*b0:<h5>::</h5>{left 5}
:*b0:<h6>::</h6>{left 5}
:*b0:<head>::</head>{left 7}
:*b0:<header>::</header>{left 9}
:*b0:<hgroup>::</hgroup>{left 9}
; :*b0:<hr>::{left 0}
:*b0:<html>::</html>{left 7}
:*b0:<i>::</i>{left 4}
:*b0:<iframe>::</iframe>{left 9}
; :*b0:<img>::{left 0}
; :*b0:<input>::{left 0}
; :*b0:<ins>::</ins>{left 6}
; :*b0:<kbd>::</kbd>{left 6}
:*b0:<label>::</label>{left 8}
:*b0:<legend>::</legend>{left 9}
:*b0:<li>::</li>{left 5}
; :*b0:<link>::{left 0}
:*b0:<main>::</main>{left 7}
:*b0:<map>::</map>{left 7}
:*b0:<mark>::</mark>{left 7}
; :*b0:<marquee>::</marquee>{left 11}
:*b0:<menu>::</menu>{left 7}
; :*b0:<meta>::{left 0}
:*b0:<meter>::</meter>{left 9}
:*b0:<nav>::</nav>{left 7}
:*b0:<nav>::</nav>{left 7}
; :*b0:<nobr>::</nobr>{left 7}
; :*b0:<noembed>::</noembed>{left 11}
; :*b0:<noframes>::</noframes>{left 11}
:*b0:<noscript>::</noscript>{left 11}
:*b0:<object>::</object>{left 9}
:*b0:<ol>::</ol>{left 5}
:*b0:<optgroup>::</optgroup>{left 11}
:*b0:<option>::</option>{left 9}
:*b0:<output>::</output>{left 9}
:*b0:<p>::</p>{left 4}
:*b0:<param>::{left 0}
:*b0:<picture>::</picture>{left 11}
; :*b0:<plaintext>::</plaintext>{left 11}
:*b0:<portal>::</portal>{left 9}
:*b0:<pre>::</pre>{left 6}
:*b0:<progress>::</progress>{left 11}
; :*b0:<q>::</q>{left 5}
; :*b0:<rb>::</rb>{left 5}
; :*b0:<rp>::</rp>{left 5}
; :*b0:<rt>::</rt>{left 5}
; :*b0:<rtc>::</rtc>{left 6}
; :*b0:<ruby>::</ruby>{left 7}
; :*b0:<s>::</s>{left 4}
; :*b0:<samp>::</samp>{left 7}
:*b0:<script>::</script>{left 9}
; :*b0:<search>::</search>{left 9}
:*b0:<section>::</section>{left 11}
:*b0:<select>::</select>{left 9}
:*b0:<slot>::</slot>{left 7}
:*b0:<small>::</small>{left 7}
:*b0:<source>::</source>{left 9}
:*b0:<span>::</span>{left 7}
:*b0:<strike>::</strike>{left 9}
:*b0:<strong>::</strong>{left 9}
:*b0:<style>::</style>{left 8}
:*b0:<sub>::</sub>{left 5}
:*b0:<summary>::</summary>{left 9}
:*b0:<sup>::</sup>{left 5}
:*b0:<table>::</table>{left 9}
:*b0:<tbody>::</tbody>{left 9}
:*b0:<td>::</td>{left 5}
:*b0:<template>::</template>{left 11}
:*b0:<textarea>::</textarea>{left 11}
:*b0:<tfoot>::</tfoot>{left 9}
:*b0:<th>::</th>{left 5}
:*b0:<thead>::</thead>{left 9}
:*b0:<time>::</time>{left 7}
:*b0:<title>::</title>{left 9}
:*b0:<tr>::</tr>{left 5}
:*b0:<track>::</track>{left 9}
; :*b0:<tt>::</tt>{left 5}
; :*b0:<u>::</u>{left 4}
:*b0:<ul>::</ul>{left 5}
:*b0:<var>::</var>{left 7}
:*b0:<video>::</video>{left 9}
; :*b0:<wbr>::{left 0}
; :*b0:<xmp>::</xmp>{left 7}