<?php header("Content-type: text/html; charset=UTF-8");
require_once("init.php");
require_once("init_ptt.php");
require_once('i18n.php');
?>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<link rel="icon" type="image/png" href="data:;base64,iVBORw0KGgo=">
<link rel="shortcut icon" href="data:image/x-icon;," type="image/x-icon">
<meta name="propeller" content="98d8ecc9b30b166f89d0410cd31b7cc0" />
<meta name="trafficjunky-site-verification" content="5t70yr82t" />
<title><?php
if (isset($html_title)) {
	echo $html_title;
}
if (strpos($_SERVER['REQUEST_URI'], 'ck101') > 0 || strpos($_SERVER['REQUEST_URI'], 'user') > 0) {
	echo i18n(' ck101 卡提諾論壇');
}
else {
	echo i18n(' PTT批踢踢實業坊');
}
?></title>
<link rel="stylesheet" href="//cdn.bootcss.com/twitter-bootstrap/3.0.3/css/bootstrap.min.css">
<link rel="stylesheet" href="//code.jquery.com/ui/1.11.3/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-2.1.4.min.js"></script>
<script src="//cdn.bootcss.com/twitter-bootstrap/3.0.3/js/bootstrap.min.js"></script>
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery.lazyload/1.9.1/jquery.lazyload.min.js"></script>
<script src="/js/auto_complete.js?v=3"></script>
<meta name="applicable-device" content="pc,mobile">
<meta name="baidu-site-verification" content="uo47eIda6W" />
<meta baidu-gxt-verify-token="b91724952823a39fa8b5dffc2858ecbb"> 
<meta property="qc:admins" content="2746676521624354063757" />
<meta name="juicyads-site-verification" content="2c392a6a7d87f4e6fb7eebb104490caf">
<meta name="ero_verify" content="415b1230f426bd7372dd51bf047c53ed" />
<style>
body,button, input, select, textarea,h1 ,h2, h3, h4, h5, h6 { font-family: 'Microsoft YaHei','宋体' , Tahoma, Helvetica, Arial, sans-serif;}
</style>
<?
if ($_SERVER['SCRIPT_NAME'] == '/index.php') {
	echo '<base target="_blank" />';
}
echo get_hreflang();
?>
<script>
var _hmt = _hmt || [];
(function() {
 var hm = document.createElement("script");
 hm.src = "//hm.baidu.com/hm.js?2d58a718ed27960a97f3c1be42d842ff";
 var s = document.getElementsByTagName("script")[0]; 
 s.parentNode.insertBefore(hm, s);
 })();
</script>
<?
if (!$is_loyal_user) {
	echo $popads_ucptt;
}
?>
</head>
<body>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-54c4990a04963235" async="async"></script>
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
 (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
 m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
 })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
ga('create', 'UA-17088225-6', 'auto');
ga('send', 'pageview');
</script>
<div class="row">
<div class="col-md-8 col-md-offset-2 col-xs-12">
<nav class="navbar navbar-default" role="navigation">
<div class="collapse navbar-collapse">
<ul class="nav navbar-nav">
<li <?if ($_SERVER['REQUEST_URI'] == '/' || strpos($_SERVER['REQUEST_URI'], '/board') === 0 || strpos($_SERVER['REQUEST_URI'], '/article') === 0 || strpos($_SERVER['REQUEST_URI'], '/thread') === 0) echo 'class="active"'?>><a href="/">PTT</a></li>
<!--
<li <?if (strpos($_SERVER['REQUEST_URI'], '/disp') === 0 || strpos($_SERVER['REQUEST_URI'], '/topic') === 0) echo 'class="active"'?>><a href="/disp">Disp</a></li>
-->
</ul>
<form class="navbar-form navbar-left" role="search" action="/select_board" method="POST">
<div class="form-group">
<input type="text" id="select_board" name="en_name" class="form-control" placeholder="<? echo i18n('xuanzekanban') ?>">
</div>
<button type="submit" class="btn btn-default">Submit</button>
</form>
<form class="navbar-form navbar-left" role="search" action="/query_author" method="POST">
<div class="form-group">
<input type="text" name="author" class="form-control" placeholder="<? echo i18n('chaxunzuozhe') ?>">
</div>
<button type="submit" class="btn btn-default">Submit</button>
</form>
<div class="btn-group navbar-right">
<button type="button" class="btn btn-default dropdown-toggle navbar-btn" data-toggle="dropdown">
<? echo i18n('xuanzeyuyan')?><span class="caret"></span>
</button>
<? if (!$is_spider) { ?>
<ul class="dropdown-menu" role="menu">
<li><a href="//www.ucptt.com<? echo $_SERVER['REQUEST_URI']; ?>">正體中文</a></li>
<li><a href="//cn.ucptt.com<? echo $_SERVER['REQUEST_URI']; ?>">简体中文</a></li>
</ul>
<? } ?>
</div>
</div>
</nav>
</div>
</div>
<div class="row">
<div class="col-md-1 col-md-offset-9 col-xs-1 col-xs-offset-9">
</div></div>
<div class="row">
