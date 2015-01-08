<?php header("Content-type: text/html; charset=UTF-8");
require_once('i18n.php');
?>
<!DOCTYPE HTML>
<html lang="<?echo get_lang_short();?>">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>
<?php
if (isset($html_title)) {
	echo $html_title;
}
?>
</title>
<link rel="stylesheet" href="http://cdn.bootcss.com/twitter-bootstrap/3.0.3/css/bootstrap.min.css">
<script src="http://cdn.bootcss.com/jquery/1.10.2/jquery.min.js"></script>
<script src="http://cdn.bootcss.com/twitter-bootstrap/3.0.3/js/bootstrap.min.js"></script>
<script src="<?echo $static_host;?>/js/jquery.lazyload.min.js"></script>
<meta name="baidu-site-verification" content="c3FkX097v5" />
<?
if (isset($target)) {
	echo "<base target=\"$target\" />";
}
?>
<script>var _hmt = _hmt || [];(function() {  var hm = document.createElement("script");  hm.src = "//hm.baidu.com/hm.js?0b4a6c1a6eedf10ee1f1702eced53914";  var s = document.getElementsByTagName("script")[0];   s.parentNode.insertBefore(hm, s);})();</script>
</head>
<body>
<div class="row"><div class="col-md-8 col-md-offset-2 col-xs-12">
<nav class="navbar navbar-default" role="navigation">
	<div class="container-fluid">
		<div class="navbar-header">
			<a class="navbar-brand" href="/">Japanese Porn Database</a>
		</div>
		<div class="collapse navbar-collapse">
			<ul class="nav navbar-nav">
				<li><a href="/list/rank/1"><?echo i18n('hottest');?></a></li>
				<li><a href="/list/release_date/1"><?echo i18n('latest');?></a></li>
			</ul>
			<form class="navbar-form navbar-left" role="search" action="/search" method="POST">
				<div class="form-group">
					<input type="text" name="sn" class="form-control" placeholder="<?echo i18n('sn');?>">
				</div>
				<button type="submit" class="btn btn-default">Search</button>
			</form>
			<div class="btn-group navbar-right">
				<button type="button" class="btn btn-default dropdown-toggle navbar-btn" data-toggle="dropdown">
					<? echo i18n('select_language')?><span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
					<li><a href="http://www.jporndb.com<? echo $_SERVER['REQUEST_URI']; ?>" target="_self">English</a></li>
					<li><a href="http://jp.jporndb.com<? echo $_SERVER['REQUEST_URI']; ?>" target="_self">日本語</a></li>
					<li><a href="http://tw.jporndb.com<? echo $_SERVER['REQUEST_URI']; ?>" target="_self">正體中文</a></li>
					<li><a href="http://cn.jporndb.com<? echo $_SERVER['REQUEST_URI']; ?>" target="_self">简体中文</a></li>
				</ul>
			</div>
		</div>
	</div>
</nav>
</div></div>
