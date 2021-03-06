#!/usr/bin/perl -w
use strict;
use DBI;
require('config.pl');
require('lib.pl');
require('db_lib.pl');

our $db_conn = init_db();
$db_conn->do('use douban');
#init_ptt_db();

my @bids = execute_column("select bid from board where featured = 1");
for my $bid (@bids) {
	for (my $start = 0; ; $start += 25) {
		my $continue = 0;
		my $url = "https://www.douban.com/group/$bid/discussion?start=$start";
		my $list_html = get_url($url);
		while ($list_html =~ /https:\/\/www\.douban\.com\/group\/topic\/(\d+)\//g) {
			my $tid = $1;
			$continue |= download_douban_topic($bid, $tid);
		}
		last if (!$continue);
	}
}
