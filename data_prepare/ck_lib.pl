require('lib.pl');


sub get_ck_boards {
	my $html = get_url('http://ck101.com/forum.php?ref=nav');
	my %board_groups;
	while ($html =~ /<li id="mn_(\w+)" onmouseover="showMenu\({'ctrlid':this\.id,'ctrlclass':'hover','duration':2}\)"><a  onclick="ga\('send','event', 'navs','([\d\D]+?)'\);"/g) {
		$board_groups{$1} = $2;
		print "$1 $2\n";
	}
	my %boards;
	while ($html =~ /<ul class="f\w+">([\d\D]+?)<\/ul>/g) {
		my $board_group_html = $1;
		if ($board_group_html =~ /<h2>([\d\D]+?)<\/h2>/) {
			if ($1 =~ /title="([\d\D]+?)"/) {
				my $board_group_name = $1;
				while ($board_group_html =~ /ck101.com\/forum-(\d+)-1\.html" title="([\d\D]+?)"/g) {
					if (!defined($boards{$1})) {
						$boards{$1} = [$board_group_name, $2];
						print "$1 $board_group_name $2\n";
					}
				}
			}
		}
	}
	while ($html =~ /<ul class="p_pop h_pop" id="mn_(\w+?)_menu" style="display: none">([\d\D]+?)<\/ul>/g) {
		my $board_group_id = $1;
		my $boards_html = $2;
		print "$1 $2\n";
		while ($boards_html =~ /<a onclick="ga\('send','event', 'navs','([\d\D]+?)'\);"\s+href="http:\/\/(.+?)"/g) {
			my $cn_name = $1;
			my $bid = 0;
			if ($2 =~ /ck101.com\/forum-(\d+)-1\.html/) {
				$bid = $1;
			}
			else {
				next;
			}
			next if (defined($boards{$bid}));
			my $board_group_name = $board_groups{$board_group_id};
			if (!defined($board_group_name)) {
				$board_group_name = '成人';
			}
			$boards{$bid} = [$board_group_name, $cn_name];
			print "$bid $board_group_name $cn_name\n";
		}
	}
	while (my ($bid, $pa) = each %boards) {
		print "$bid\t$pa->[0]\t$pa->[1]\n";
		$db_conn->do("replace into board(id, group_name, cn_name) values($bid, '$pa->[0]', '$pa->[1]')");
	}
	return \%boards;
}

sub get_ck_boards_from_db {
	my $boards = execute_dataset("select id, group_name, cn_name from board");
	my %boards;
	for my $board (@$boards) {
		$boards{$board->[0]} = [$board->[1], $board[2]];
	}
	return \%boards;
}

sub get_ck_topics {
	my $bid = $_[0];
	for (my $page = 1; $page < 1000000; ++$page) {
		my $url = "http://www.ck101.com/forum-$bid-$page.html?ref=nav";
		print "board $bid $page\n";
		my $html = get_url($url);
		my @topics;
		while ($html =~ /<tbody id="normalthread_(\d+)"([\d\D]+?)<\/tbody>/g) {
			my ($tid, $span) = ($1, $2);
			my ($author, $pub_time, $title);
#			if ($span =~ /ck101\.com\/space-uid-\d+.html"\s*>([\d\D]+?)<\/a><\/cite>/) {
#			if ($span =~ /<a class="ellipsis" href="home.php\?mod=space&amp;uid=\d+"\s*>([\d\D]+?)<\/a>/) {
#				$author = $1;
#			}
			if ($span =~ /<\/cite>\s*<br>\s*<span>([\d\-\s:]+)<\/span>/) {
				$pub_time = "$1:00";
			}
			if (!defined($pub_time)) {
				if ($span =~ /<\/cite>\s*<span>([\d\-\s:]+)<\/span>/) {
					$pub_time = "$1:00";
				}		
			}
			if (!defined($pub_time)) {
				$pub_time = "$1:00" if ($span =~ /<span class="xi1">([\d\-\s:]+)<\span>/)
			}
			if ($span =~ /<h2>([\d\D]+?)<\/h2>/g) {
				$title = $1;
			}
			if (!defined($pub_time) || !defined($title)) {
				print "ERROR list $bid $page $tid $author $pub_time $title\n";
			}
			else {
				push @topics, [$bid, $tid, $title, $author, $pub_time];
				print "$tid, $title, $pub_time\n";
			}
		}
		if (!download_ck_topics(@topics)) {
			last;
		}
#		last;
	}
	print "exit board $bid\n";
}

my $replace_tmp_br = 'ccckkk111000111';

sub download_ck_topics {
	my $found = 0;
	foreach my $topic (@_) {
		my ($bid, $tid, $title, $author, $pub_time) = @$topic;
		my $saved_article_num = execute_scalar("select count(*) from article where tid = $tid");
		next if ($saved_article_num >= 1);
#		$tid = 3255106;
		my $url = "http://ck101.com/thread-$tid-1-1.html";
		my $html = get_url($url);
		my @spans = split(/div id="post_\d+" class="plhin">/, $html);
		#my @spans = split('class="plhin">', $html);
		my @articles;
		for (my $i = 1; $i < @spans; ++$i) {
			my $span = $spans[$i];
			#print "spans $i $span\n";
			my ($aid, $author, $pub_time, $content);
#			$aid = $1 if ($span =~ /<table id="pid(\d+)" class="plhin"/);
			$aid = $1 if ($span =~ /div id="favatar(\d+)/);
			$author = $1 if (!defined($author) && $span =~ /title="([^"]+?)"\s+class="authorName"/);
			if (!defined($author)) {
				$author = $1 if ($span =~ /<div class="pi">\s*([\d\D]+?)\s*<em>該用戶已被刪除<\/em>/);
			}
			if (!defined($author)) {
				$author = '';
			}
			$topic->[3] = $author if (!defined($topic->[3]));
			$pub_time = $1 if ($span =~ /class="postDateLine">發表於 ([\d\-\s:]+)<\/span>/);
			if (!defined($pub_time)) {
				if (@articles > 0) {
					$pub_time = $articles[@articles - 1]->[2];
				}
				else {
					$pub_time = '2000-01-01 00:00';
				}
			}
			$content = $1 if ($span =~ /id="postmessage_\d+">\s*([\d\D]+?)\s*<\/td>/);
			next if (!defined($aid));
			if (!defined($author) || !defined($pub_time) || !defined($content)) {
				print "ERROR $aid $url $author $pub_time $content\n";
				next;
			}
			$pub_time = "$pub_time:00";
			$content =~ s/<br \/>\s*/$replace_tmp_br/g;
			$content =~ s/<.+?>//g;
			$content =~ s/$replace_tmp_br/<br \/>/g;
			print "reply\t$aid $author $pub_time\n";
			push @articles, [$aid, $author, $pub_time, $content];
		}
		my $reply_num = $html =~ /回覆:(\d+) | 感謝：/ ? $1 : 0;
		push @$topic, $reply_num;
		save_topic($topic);
		next if ($saved_article_num == @articles);
		$found |= save_articles($tid, @articles);
	}
	return $found;
}

sub save_topic {
	my $topic = shift;
	my ($bid, $tid, $title, $author, $pub_time, $reply_num) = @$topic;
	$title = $db_conn->quote($title);
	$db_conn->do("replace into topic(bid, tid, title, author, pub_time, reply_num) values($bid, $tid, $title, '$author', '$pub_time', $reply_num)");
}

sub save_articles {
	my $tid = shift;
	if (execute_scalar("select count(*) from article where tid = $tid") == @_) {
		return 0;
	}
	foreach my $article (@_) {
		my ($aid, $author, $pub_time, $content) = @$article;
		if (execute_scalar("select count(*) from article where aid = $aid") > 0) {
			next;
		}
		$content = $db_conn->quote($content);
		$db_conn->do("insert into article(tid, aid, author, pub_time, content) values($tid, $aid, '$author', '$pub_time', $content)");
	}
	return 1;
}

1;
