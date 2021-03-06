#!/usr/bin/perl -w
use strict;
use utf8;
use Encode;
use HTML::Entities;
use Test::JSON;
no warnings 'utf8';

our $db_conn;
sub get_groups {
        my $url = 'https://www.zhihu.com/topics';
        my $html = get_url($url);
        my @groups = ();
        while ($html =~ /<li .+?data-id="(\d+)"><a href="#([\d\D]+?)">/g) {
			push @groups, [$1, $2];
			print "$1, $2\n";
			$db_conn->do("replace into board values($1, '$2')");
        }
        return \@groups;
}
my $json_parser = new JSON;

sub get_boards {
        my $group = $_[0];
        my ($board_id, $board_name) = @$group;
        my $url = 'https://www.zhihu.com/node/TopicsPlazzaListV2';
        my @boards;
        for (my $offset = 0; ; $offset += 20) {
                my %form = (
                                'method' => 'next',
                                'params' => '{"topic_id":'.$board_id.',"offset":'.$offset.',"hash_id":"9fc675d1e89601361f31576d9b2724dd"}',
                                '_xsrf' => '777e3e3c5616ac059706b4d409203647'
                           );
                my $html = post_url($url, \%form);
		if (index($html, '{') != 0) {
			print "skip malformed json\n$html\n";
			sleep(1);
			next;
		}
                my $json = $json_parser->decode($html);
                my $pa = $json->{'msg'};
                foreach my $item (@$pa) {
                        my $img = $1 if ($item =~ /\.zhimg\.com\/(\w+?)_xs\.jpg/);
                        my $sb_name = $1 if ($item =~ /<strong>([\d\D]+?)<\/strong>/);
                        my $sbid = $1 if ($item =~ /\/topic\/(\d+)/);
#                       print "$board_id\t$board_name\t$img\n";
                        push @boards, [$board_id, $board_name, $sbid, $sb_name];
                        $db_conn->do("replace into sub_board values($sbid, $board_id, ".add_slashes($sb_name).")");
                }
                last if (@$pa < 20);
#		last;
        }
        return \@boards;
}

sub get_zhihu_questions {
        my $board = $_[0];
        my ($board_id, $board_name, $sbid, $sb_name) = @$board;
        my $url = "https://www.zhihu.com/topic/$sbid/newest";
        my $time = time();
	my $now = time();
        my %questions;
		while (1) {
			my %form = (
				start => 0,
				#offset => $time.'.0',
				offset => $time,
				_xsrf => '777e3e3c5616ac059706b4d409203647'
		   );
			my $html = post_url($url, \%form);
#			if (index($html, '{') != 0 || rindex($html, '}') != length($html) - 1) {
			if (!is_valid_json($html)) {
				print "skip malformed json\n$html\n";
				sleep(1);
				next;
			}
			my $json = $json_parser->decode($html);
			my @arr = split('http://schema.org/Question', $json->{'msg'}->[1]);
			foreach my $item (@arr) {
				$time = $1 if ($item =~ /data-timestamp="(\d+?)000"/ && $time > $1);
#               my ($sb_id, $sb_name) = (0, '');
#               ($sb_id, $sb_name) = ($1, $2) if ($item =~ /href="\/topic\/(\d+)">([\d\D]+?)<\/a>/);
				my ($qid, $title) = ($1, $2) if ($item =~ / href="\/question\/(\d+)".+?>([\d\D]+?)\s*<\/a>/);
				next if (!defined($qid));
				next if (index($title, 'itemprop="answerCount" content="0"') > 0);
				next if ($qid == 41948235);
				my $author = $1 if ($item =~ /href="\/people\/.+?">([\d\D]+?)<\/a>/);
				if (!defined($author)) {
#					print "question id $qid author not found\n";
					$author = '';
				}
				print "question\t$time\t$sbid\t$sb_name\t$qid\t$author\t$title\n";
				$questions{$qid} = [$board_id, $board_name, $sbid, $sb_name, $time, $qid, $title];
			}
			last if (@arr < 20);
			last if ($now - $time > 60 * 60 * 24 * 2);
#		last;
        }
        return \%questions;
}

sub get_zhihu_question {
        my $question = $_[0];
        my ($board_id, $board_name, $sb_id, $sb_name, $time, $qid, $title) = @$question;
#	$qid = 30055018;
        my $url = "https://www.zhihu.com/question/$qid";
        my $html = get_url($url);
#       print $html;
#	   exit;
#       return;
        #my $q_title = $1 if ($html =~ /<h2 class="zm-item-title zm-editable-content">\s*([\d\D]+?)\s*<\/h2>/);
	my $q_title = $1 if ($html =~ /<span class="zm-editable-content">([\d\D]+?)<\/span>/);
	my $q_content = undef;
	$q_content = $1 if ($html =~ /<textarea class="content hidden">\s*([\d\D]+?)\s*<\/textarea>/);
	if (defined($q_content) && $q_content ne '') {
		$q_content = decode_entities($q_content);
	}
	if (!defined($q_content) || $q_content eq '') {
        	$q_content = $1 if ($html =~ /<div class="zm\-editable\-content">\s*([\d\D]*?)\s*<\/div>/);
	}
	if (!defined($q_content) || $q_content eq '') {
		$q_content = $1 if ($html =~ /<div class="zh-summary summary clearfix">\s*([\d\D]*?)<a href="javascript/);
	}
	$q_title = decode('utf8', $q_title);
#	my $original_q_content = $q_content;
#      	print "question $q_title $q_content\n";
	eval {
		$q_content = decode('utf8', $q_content);
	};
	if ($@) {
		print "empty q_content $@\n";
#		print $html;
	}
#       print "question $q_title $q_content\n";
#	$q_title = decode('Guess', $q_title);
#	$q_content = decode('Guess', $q_content);
# 	print "question $q_title $q_content\n";
#	my $q_log_html = get_url("http://www.zhihu.com/question/$qid/log");
	my $q_uid = execute_scalar("select uid from question where qid = $qid");
	if ($q_uid eq '0') {
		$q_uid = '';
		my $q_log_html = decode('utf-8', get_https("https://www.zhihu.com/question/$qid/log"));
		$q_uid = $1 if ($q_log_html =~ /href="\/people\/([\w\-]+?)">[\S]+?<\/a>\s*<span class="zg-gray-normal">添加了问题<\/span>/);
	}
	if (execute_scalar("select count(*) from question where qid = $qid") == 0) {
		$db_conn->do("replace into question(qid, bid, sbid, uid, title, content) values($qid, $board_id, $sb_id, '$q_uid', ".add_slashes($q_title).", ".add_slashes($q_content).")");
	}
#	$db_conn->do("replace into question(qid, bid, sbid, title, content) values($qid, $board_id, $sb_id, '$q_title', '$q_content')");
	#print "replace into question(qid, bid, sbid, title, content) values($qid, $board_id, $sb_id, '$q_title', '$q_content')\n";
	print "question $qid $board_id $sb_id $q_uid $q_title\n";
        my @arr = split('class="zm-item-answer ', $html);
        foreach my $item (@arr) {
#                my $ups = $1 if ($item =~ /<span class="count">([\-\d]+)<\/span>/);
		my $ups = 0;
		$ups = $1 if ($item =~ /data\-votecount="(\d+)">/);
                my $aid = $1 if ($item =~ /name="answer-(\d+)"/);
                next if (!defined($aid));
                my ($author, $uid, $nick) = ('', '', '');
#($author, $nick) = ($1, $2) if ($item =~ /href="\/people\/[\w\-]+?">([^<]+?)<\/a>，<strong title="([\d\D]+?)"/);
        ($uid, $author) = ($1, $2) if ($item =~ /href="\/people\/([\w\-]+?)"\s*>([^<]+?)<\/a>/);
		$nick = $1 if ($item =~ /<strong title="([\d\D]+?)"/g);
		if ($nick eq '') {
			$nick = $1 if ($item =~ /<span title="([\d\D]+?)" class="bio">/);
		}
                my $pub_time = $1 if ($item =~ /data-created="(\d+)"/);
                if (defined($pub_time) && $pub_time =~ /:/) {
                        print "pub_time malform\n";
                }
                else {
                        $pub_time = get_datetime_string($pub_time);
                }
                my $content = '';
                $content = $1 if ($item =~ /<div class="[\w\-\s]*zm\-editable\-content clearfix">\s*([\d\D]+?)\s*<\/div>/);
		if (!defined($content)) {
			$content = $1 if ($item =~ /<div class="fixed-summary zm-editable-content clearfix">\s*([\d\D]+?)\s*<\div>/);
			$content =~ s/<div class="fixed-summary-mask">//;
		}
		my $comment_num = 0;
		$comment_num = $1 if ($item =~ /<i class="z-icon-comment"><\/i>(\d+)/);
		$author = decode('utf8', $author);
		$nick = decode('utf8', $nick);
		$content = decode('utf8', $content);
		$content = process_answer_content($content);
		my $pic = is_pic_answer($content, $ups);
		my $good = is_good_answer($content, $ups);
		my $hot = ($ups >= 50 ? 1 : 0);
		if (!defined($content) || $content eq '') {
			print "$qid $aid empty answer\n";
			next;
		}
		if (execute_scalar("select count(*) from answer where aid = $aid") == 0) {
				$db_conn->do("insert into answer(aid, bid, sbid, qid, ups, author, nick, pub_time, content, good, hot, pic) values($aid, $board_id, $sb_id, $qid, $ups, ".add_slashes($author).", ".add_slashes($nick).", '$pub_time', ".add_slashes($content).", $good, $hot, $pic)");
		}
		else {
			$db_conn->do("update answer set ups = $ups, content = ".add_slashes($content).", ups = $ups, good = $good, hot = $hot, pic = $pic where aid = $aid");
		}
#print "answer\t$aid $ups $comment_num $author $nick $pub_time ".substr($content, 0, 20)."\n";
	#download_user_info($uid);
		print "answer\t$aid $ups $comment_num $author $nick $pub_time\n";
#               print "item $item\n";
#               exit;
		next if ($comment_num == 0);
		next if (execute_scalar("select count(*) from comment where aid = $aid") >= $comment_num);
#		my $comment_url = "http://www.zhihu.com/node/AnswerCommentListV2?params=%7B%22answer_id%22%3A%22$aid%22%7D";
		my $comment_url = "https://www.zhihu.com/node/AnswerCommentBoxV2?params=%7B%22answer_id%22%3A%22$aid%22%2C%22load_all%22%3Atrue%7D";
		my $comment_html = get_url($comment_url);
#               print $comment_html;
#               next;
		my $comment_ups_max = 0;
		my $best_comment_length = 0;
                my @comments = split('zm-item-comment', $comment_html);
                foreach my $comment (@comments) {
                        my $comment_id = $1 if ($comment =~ /name="comment\-(\d+)"/);
                        next if (!defined($comment_id) || $comment_id == 0);
                        my $commenter = '';
                        $commenter = $1 if ($comment =~ /class="zg\-link author\-link" title="([\d\D]+?)"/);
						my $commenter_uid = '';
						$commenter_uid = $1 if ($comment =~ /\/people\/([\w\-]+?)"/);
                        my $comment_content = $1 if ($comment =~ /<div class="zm-comment-content">\s*([\d\D]*?)\s*<\/div>/);
						if (!defined($comment_content)) {
							print "undefined comment content $comment_url $comment\n";
						}
			next if ($comment_content eq '');
			my $comment_ups = 0;
            $comment_ups = $1 if ($comment =~ /<em>(\d+)<\/em>/);
			if ($comment_ups_max < $comment_ups) {
				$comment_ups_max = $comment_ups;
				$best_comment_length = length($comment_content);
			}
                        my $comment_date = '2000-01-01';
                        if ($comment =~ /<span class="date">([\d\-]+)/) {
                                $comment_date = $1;
				if (length($comment_date) < 8) {
					$comment_date = get_date_str(0);
				}
                        }
                        elsif ($comment =~ /<span class="date">昨天\s*([\d:]+)/) {
                                $comment_date = get_date_str(-1);
                        }
			else {
				$comment_date = get_date_str(0);
			}
#                       next if (execute_scalar("select count(*) from comment where cid = $comment_id") > 0);
                        print "comment $comment_id $commenter $comment_ups $comment_date\n";
#                       print $comment;
#                       exit;
			if (execute_scalar("select count(*) from comment where cid = $comment_id") == 0) {
				$db_conn->do("insert into comment(cid, aid, author, ups, pub_date, content) values($comment_id, $aid, ".add_slashes($commenter).", $comment_ups, '$comment_date', ".add_slashes($comment_content).")");
			}
			else {
				$db_conn->do("update comment set ups = $comment_ups where cid = $comment_id");
			}
                }
		my $reply = ($comment_ups_max >= 30 && $comment_ups_max * 2 >= $ups) && $best_comment_length < 140 ? 1 : 0;
		if (1 || $reply) {
			$db_conn->do("update answer set reply = $reply where aid = $aid");
		}
        }
}

sub process_answer_content {
	my $content = shift;
	return $content;
}

sub is_good_answer {
	my ($content, $ups) = @_;
	if ($ups < 25) {
		return 0;
	}
	return 0 if (length($content) < 2);
#	return 0 if (index($content, '<img') > 0);
	$content =~ s/<script.*?<\/script>//sg;
	$content =~ s/<.+?>//sg;
	if (length($content) < 70) {
		return 1;
	}
	return 0;
}

sub is_pic_answer {
	my ($content, $ups) = @_;
	if ($ups < 30) {
		return 0;
	}
	my ($pos, $pic_count) = (-1, 0);
	do {
		$pos = index($content, '<img', $pos + 1);
		$pic_count++ if ($pos >= 0);
	} while ($pos >= 0);
	return 0 if ($pic_count == 0);
	$content =~ s/<script.*?<\/script>//sg;
	$content =~ s/<.+?>//sg;
	if (length($content) / $pic_count < 70) {
		return 1;
	}
	return 0;
}

sub download_user_info {
	#return;
	my $uid = shift;
	return if (!defined($uid) || $uid eq '');
	return if (execute_scalar("select count(*) from user where uid = '$uid'") == 1);
	#my $html = get_https("https://www.zhihu.com/people/$uid/about");
	my $html = get_https("https://www.zhihu.com/people/$uid");
	#print $html;
	#exit;
	my ($name, $nick, $location, $business, $gender, $ups, $thanks, $asks, $answers, $posts, $collections, $education, $major, $employment, $position) = ('', '', '', '', 0, 0, 0, 0, 0, 0, 0, '', '', '', '');
	#$name = $1 if ($html =~ /href="\/people\/$uid">([\d\D]+?)<\/a>/);
	$name = $1 if ($html =~ /<title> ([\d\D]+?) /);
	$nick = $1 if ($html =~ /<span class="bio" title="([\d\D]+?)">/);
	$location = $1 if ($html =~ /<span class="location item" title="([\d\D]+?)">/);
	$business = $1 if ($html =~ /<span class="business item" title="([\d\D]+?)">/);
	if (index($html, '<i class="icon icon-profile-male">') > 0) {
		$gender = 1;
	}
	elsif (index($html, '<i class="icon icon-profile-female">') > 0) {
		$gender = 2;
	}
	$employment = $1 if ($html =~ /<span class="employment item" title="([\d\D]+?)">/);
	$position = $1 if ($html =~ /<span class="position item" title="([\d\D]+?)">/);
	$education = $1 if ($html =~ /<span class="education item" title="([\d\D]+?)">/);
	$major = $1 if ($html =~ /<span class="education-extra item" title='([\d\D]+?)'>/);
	$asks = $1 if ($html =~ /\/asks">\s*提问\s*<span class="num">(\d+)<\/span>/);
	$answers = $1 if ($html =~ /\/answers">\s*回答\s*<span class="num">(\d+)<\/span>/);
	$posts = $1 if ($html =~ /\/posts">\s*文章\s*<span class="num">(\d+)<\/span>/);
	$ups = $1 if ($html =~ /<span class="zm-profile-header-user-agree"><span class="zm-profile-header-icon"><\/span><strong>(\d+)<\/strong>/);
	$thanks = $1 if ($html =~ /<span class="zm-profile-header-user-thanks"><span class="zm-profile-header-icon"><\/span><strong>(\d+)<\/strong>/);
	print "$uid, $name, $nick, $location, $business, $gender, $ups, $thanks, $asks, $answers, $posts, $collections, $education, $major, $employment\n";
	$db_conn->do("replace into user(uid, name, nick, location, business, gender, education, major, employment, position, ups, thanks, asks, answers, posts, collections) values('$uid', 
	".$db_conn->quote($name).",
	".$db_conn->quote($nick).", "
	.$db_conn->quote($location).", "
	.$db_conn->quote($business).", "
	."$gender, "
	.$db_conn->quote($education).", "
	.$db_conn->quote($major).", "
	.$db_conn->quote($employment).", "
	.$db_conn->quote($position).", "
	."$ups, $thanks, $asks, $answers, $posts, $collections)");
	$html = decode('utf-8', $html);
	while ($html =~ /${name}在([\d\D]+?)下的回答"/g) {
		print "topic selection $uid $1\n";
		$db_conn->do("replace into topic_selection(uid, topic) values('$uid', ".$db_conn->quote($1).")");
	}
}

1;
