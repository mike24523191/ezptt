</div>
<script> 
var interval = setInterval(function(){
	$("img").lazyload();
	clearInterval(interval);
},1000);
$(function() { 
				$("img").lazyload({ 
effect : "fadeIn" 
}); 
				}); 
</script>
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
 (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
 m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
 })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-17088225-5', 'auto');
ga('send', 'pageview');

</script>
<p align="center">Contact: admin{a[_()_]t}duanzhihu.com</p>
<?
if ($is_spider) {
	echo '<p align="center"><a href="http://www.btsmth.org/">水木清华社区</a> <a href="http://www.ucptt.com/">ptt</a> <a href="http://www.jporndb.com/">japan av porn</a> <a href="http://www.zhuishubao.com/">追书宝</a> <a href="http://www.redditfun.com/">reddit</a></p>';
}
if (false || $is_google_spider) {
	if (!isset($title) || $title == '') $title = '短知乎';
	echo '<a href="http://tw.duanzhihu.com'.$_SERVER['REQUEST_URI'].'">'.$html_title.'</a>';
}
?>
</body></html>
