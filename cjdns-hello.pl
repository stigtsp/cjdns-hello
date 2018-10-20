#!/usr/bin/env perl
use Mojolicious::Lite;


# Documentation browser under "/perldoc"
#plugin 'PODRenderer';

use lib './lib', './lib/cjdns_tool/lib';

use Cjdns::RPC;

helper 'rpc' => sub {
    return do {
        my $r = new Cjdns::RPC('127.0.0.1', 11234, 'NONE');
        $r->ping();
        $r->cookie();
        $r->ping_auth();
        $r;
    };

};

helper 'rpc_unauth' => sub {
    my $rpc = shift->rpc;
    my $query = $rpc->_build_query_unauth(@_);
    return $rpc->_sync_call($query);
};

helper 'rpc_auth' => sub {
    my $rpc = shift->rpc;
    my $query = $rpc->_build_query_auth(@_);
    return $rpc->_sync_call($query);
};


helper 'color' => sub {
    return 'lightyellow';
};


helper 'table' => sub {
    my ($c, $rows, @want_cols) = @_;
    my (@cols) = @want_cols ;# || sort keys %{$rows->[0]};     
    my $gen_row = sub {
        my @cells = @_;
        return q[<tr>]. join('', map {qq[<td>${_}</td>]} @cells).q[</td></tr>];
    };
    
    my @out = &$gen_row(@cols);
    
    foreach my $r (@$rows) {
        push @out, &$gen_row(map { $r->{$_} } @cols);
    }
    return "<table>" . (join '', @out) . "</table>";
};


get '/' => sub {
    my $c = shift;
    $c->rpc->trace(1);

    my $me = $c->rpc_auth('NodeStore_nodeForAddr', id=>0)->{result};
    $c->stash('me', $me);

    $c->render(template => 'index');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<div class="box blue right" style="text-align:right">
  You're connecting from <br><b><%= $c->tx->remote_address %></b>
  </div>

% my $ip = stash('me')->{bestParent}->{ip};
% my ($short2,$short) = $ip =~ m/([a-f0-9]{4})\:([a-f0-9]{4})$/;

<h1><a href="">hyperboria</a> node

<strong style="font-weight:normal;color:#999;"><%= $short2 %>:</strong><strong><%= $short %></strong>
</strong></h1>

<div class="box green">
<strong><%= $ip %></strong>
  %#== dumper rpc_auth('ipTunnel_listConnections');
</div>

  <h2>Peers</h2>
  <pre><%== table(rpc_unauth('InterfaceController_peerStats')->{peers}, qw(lladdr user state bytesIn bytesOut addr)) %>
</pre>

</pre>
  %#==  dumper rpc_auth('NodeStore_nodeForAddr', id => 0);
  %#== dumper(rpc_query(rpc->ping));
  %#= dumper(rpc_query('InterfaceController_peerStats'));
<pre>
</pre>

<pre> <%#= dumper rpc->Admin_availableFunctions %></pre>


@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title>
  <style>
table tr:first-child {
  font-weight:bold;
  font-style:italic;
  font-color:#666;
}
.right {
    float:right;
  }
  h1 {

}
  * { color: #333; font-family: "Courier New" !important; }
  strong {
    font-size:1.5em;
    text-shadow: 0px 0px 6px rgba(199,240,255,0.7);
  }
  a {color: #666; }
  .blue { background-color: #efefff; }
  .green { background-color: #efffff; }
  .box {  min-width:50%; border: 1px solid black; padding:1em; }
  </style>
  </head>
  <body><%= content %></body>
</html>

