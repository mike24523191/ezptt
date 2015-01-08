<?
require_once("init.php");
require_once("zhihu_lib.php");
$is_spider = is_spider();
$is_from_search_engine = is_from_search_engine();

$aid = $_GET['aid'];
$db_conn = conn_db();
mysql_select_db('zhihu', $db_conn);
mysql_query('set names utf8');
list($bid, $sbid, $qid, $title, $q_content, $ups, $author, $nick, $a_content, $pub_time) = execute_vector("select question.bid, answer.sbid, question.qid, title, question.content, ups, author, nick, answer.content, pub_time from question, answer where aid = $aid and question.qid = answer.qid");
$bname = execute_scalar("select name from board where bid = $bid");
if ($sbid != 0) {
	$sb_name = execute_scalar("select name from sub_board where sbid = $sbid");
}
$html_title = "$title $author";
$articles[] = array('', '', 0, $title, $q_content, '');
$articles[] = array($author, $nick, $ups, '', $a_content, $pub_time);
$result = mysql_query("select author, ups, content, pub_date from comment where aid = $aid order by ups desc, pub_date desc");
while(list($author, $ups, $content, $pub_date) = mysql_fetch_array($result)) {
	if ($is_spider) {
		$pub_date = date("Y-m-d");
	}
	$articles[] = array($author, '', $ups, '', $content, $pub_date);
}
if (count($articles) == 1 && $is_spider) {
	$articles[] = $articles[0];
}
$other_answers = execute_dataset("select aid, author, ups, content from answer where qid = $qid order by ups desc limit 6");

$html .= "<div class=\"col-md-8 col-md-offset-2 col-xs-12\"><ol class=\"breadcrumb\"><li><a href=\"/\">知乎</a></li><li><a href=\"/topic/$bid/\">$bname</a></li><li><a href=\"/topic/$sbid\">$sb_name</a></li>";
if (false && isset($sb_name)) {
	$html .= "<li>$sb_name</li>";
}
$html .= "</ol><h3>$title</h3>";

if (!$is_loyal_user) {
//	$html .= $google_320_100;
//	$html .= $chitika_468_60;
//	$html .= $bloggerads_banner;
//	$html .= $scupio_728_90;
//	$html .= $adcash_popunder;
}
$floor = 1;
foreach ($articles as $article) {
	list($author, $nick, $ups, $title, $content, $pub_time) = $article;
	if ($floor > 1 || $content != '') {
		$html .= '<div class="panel panel-info">';
		if ($floor > 1) {
			$html .= '<div class="panel-heading">';
			if ($author == '') $author = '知乎用户';
			$html .= $author;
			if ($nick != '') {
				$html .= " &nbsp; ($nick)";
			}
			$html .= " &nbsp; &nbsp; <span class=\"glyphicon glyphicon-thumbs-up\"></span> $ups";
			$html .= "<span class=\"pull-right\">$pub_time</span>";
			$html .= '</div>';
		}
		if ($content <> '') {
			$html .= '<div class="panel-body">';
			if ($floor == 2) {
				$content = process_answer_content($content, $aid);
			}
			$html .= $content;
			$html .= '</div>';
		}
		$html .= '</div>';
	}
	if (!$is_loyal_user) {
		if ($floor == 1 || $floor == 2) {
//			$html .= $scupio_728_90;
		}
		else if ($floor == 3) {
//			$html .= $digitalpoint_468_60;
//			$html .= $bloggerads_banner;
		}
	}
	if ($floor == 2) {
		if (count($other_answers) > 1) {
			$html .= '<div class="panel panel-default"><div class="panel-heading">其他回答</div>';
			$html .= '<div class="list-group">';
			foreach ($other_answers as $other_answer) {
				list($other_aid, $other_author, $other_ups, $other_content) = $other_answer;
				if ($aid == $other_aid) continue;
				$other_content = mb_substr(strip_tags($other_content), 0, 70, 'utf-8');
				$html .= "<a href=\"/answer/$other_aid\" class=\"list-group-item\">$other_author：$other_content<span class=\"pull-right\"><span class=\"glyphicon glyphicon-thumbs-up\"></span> $other_ups</span></a>";
			}
			$html .= '</div></div>';
		}
	}
	++$floor;
}
/*
if (isset($prev_topics)) {
		$html .= '<div class="panel panel-default"><div class="panel-heading">'.i18n('jixuyuedu').'</div>';
		$html .= '<div class="list-group">';
		foreach ($prev_topics as $topic) {
				list($title, $tid1, $tid2) = $topic;
				$html .= "<a href=\"/article/$en_name/$tid1/$tid2\" class=\"list-group-item\">".i18n($title)."</a>";
		}
		$html .= '</div></div>';
}
*/
if (false || $is_spider) {
	$html .= get_rand_zhihu_topic_html();
}
if (true || $is_spider) {
#	$html .= get_old_ck101_topic_html();
}
//$html .= '<p><a href="/">PTT</a> <a href="/disp">disp</a></p></div>';
//$html .= '<script type="text/javascript">var zx_aid = 1;var zx_uid = 10799;var zoneid = 11554;</script><script type="text/javascript" charset="utf-8" src="http://click.9cpc.com/view.js"></script>';
$html .= '</div>';

require_once('header.php');
echo $html;
require_once('footer.php');
?>
