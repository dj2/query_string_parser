# coding:utf-8

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'query_string_parser'

describe 'QueryStringParser' do
  include QueryStringParser

  it 'should parse a well formed query string' do
    h = qs_parse('a=b&c=d&e=f')
    h['a'].should == 'b'
    h['c'].should == 'd'
    h['e'].should == 'f'
  end

  it 'should parse a nil query string' do
    qs_parse(nil).should == {}
  end

  it 'should allow different delimiters' do
    h = qs_parse('a=b|c=d|e=f', '|')
    h['a'].should == 'b'
    h['c'].should == 'd'
    h['e'].should == 'f'
  end

  it 'should parse a blank query string' do
    qs_parse("").should == {}
  end

  it 'should parse a query string with multiple delimiters together' do
    h = qs_parse("appkey=ff-postrank&&id=http%3A%2F%2Fmail.google.com%2Fmail%2Ffeed%2Fatom")
    h.keys.length.should == 2
    h['appkey'].should == 'ff-postrank'
    h['id'].should == 'http://mail.google.com/mail/feed/atom'
  end

  it 'should parse a key with no value at the end of the string' do
    h = qs_parse("appkey=ff-postrank&id=http%3A%2F%2Fmail.google.com%2Fmail%2Ffeed%2Fatom&noindex")
    h.keys.length.should == 3
    h['appkey'].should == 'ff-postrank'
    h['id'].should == 'http://mail.google.com/mail/feed/atom'
    h['noindex'].should == 'noindex'
  end

  it 'should parse a key with no value at the beginning of the string' do
    h = qs_parse("noindex&appkey=ff-postrank&id=http%3A%2F%2Fmail.google.com%2Fmail%2Ffeed%2Fatom")
    h.keys.length.should == 3
    h['appkey'].should == 'ff-postrank'
    h['id'].should == 'http://mail.google.com/mail/feed/atom'
    h['noindex'].should == 'noindex'
  end

  it 'should parse a key with no value in the middle of the string' do
    h = qs_parse("appkey=ff-postrank&noindex&id=http%3A%2F%2Fmail.google.com%2Fmail%2Ffeed%2Fatom")
    h.keys.length.should == 3
    h['appkey'].should == 'ff-postrank'
    h['id'].should == 'http://mail.google.com/mail/feed/atom'
    h['noindex'].should == 'noindex'
  end

  it 'should handle receiving only a key without a value' do
    h = qs_parse('noindex')
    h.keys.length.should == 1
    h['noindex'].should == 'noindex'
  end

  it 'should parse a string with only =' do
    qs_parse("=").should == {}
  end

  it 'should parse a string with only &' do
    qs_parse('&').should == {}
  end

  it 'should parse a key with a blank value' do
    h = qs_parse("mykey=&otherkey=zsf")
    h.keys.length.should == 2
    h['mykey'].should == ''
    h['otherkey'].should == 'zsf'
  end

  it 'should parse a value with no key' do
    h = qs_parse("mykey=asdf&=myvalue")
    h.keys.length.should == 1
    h['mykey'].should == 'asdf'
  end

  it 'should handle arrays of values' do
    h = qs_parse("url[]=http%3A%2F%2Fscience.slashdot.org%2Farticle.pl%3Fsid%3D08%2F09%2F23%2F1210218%26from%3Drss&feed_id[]=132&url[]=http%3A%2F%2Fhardware.slashdot.org%2Farticle.pl%3Fsid%3D08%2F09%2F23%2F0313242%26from%3Drss&feed_id[]=132")
    h['url'].class.should == Array
    h['url'].length.should == 2
    h['url'][0].should == 'http://science.slashdot.org/article.pl?sid=08/09/23/1210218&from=rss'
    h['url'][1].should == 'http://hardware.slashdot.org/article.pl?sid=08/09/23/0313242&from=rss'

    h['feed_id'].class.should == Array
    h['feed_id'].length.should == 2
    h['feed_id'][0].should == '132'
    h['feed_id'][1].should == '132'
  end

  it 'should handle arrays of values with indexes' do
    h = qs_parse("url[0]=http%3A%2F%2Fscience.slashdot.org%2Farticle.pl%3Fsid%3D08%2F09%2F23%2F1210218%26from%3Drss&feed_id[0]=132&url[1]=http%3A%2F%2Fhardware.slashdot.org%2Farticle.pl%3Fsid%3D08%2F09%2F23%2F0313242%26from%3Drss&feed_id[1]=132")
    h['url'].class.should == Array
    h['url'].length.should == 2
    h['url'][0].should == 'http://science.slashdot.org/article.pl?sid=08/09/23/1210218&from=rss'
    h['url'][1].should == 'http://hardware.slashdot.org/article.pl?sid=08/09/23/0313242&from=rss'

    h['feed_id'].class.should == Array
    h['feed_id'].length.should == 2
    h['feed_id'][0].should == '132'
    h['feed_id'][1].should == '132'
  end

  it "should handle escaped []'s on array keys" do
    h = qs_parse("url%5B%5D=http%3A%2F%2Fscience.slashdot.org%2Farticle.pl%3Fsid%3D08%2F09%2F23%2F1210218%26from%3Drss&feed_id%5B%5D=132&url%5B%5D=http%3A%2F%2Fhardware.slashdot.org%2Farticle.pl%3Fsid%3D08%2F09%2F23%2F0313242%26from%3Drss&feed_id%5B%5D=132")
    h['url'].class.should == Array
    h['url'].length.should == 2
    h['url'][0].should == 'http://science.slashdot.org/article.pl?sid=08/09/23/1210218&from=rss'
    h['url'][1].should == 'http://hardware.slashdot.org/article.pl?sid=08/09/23/0313242&from=rss'

    h['feed_id'].class.should == Array
    h['feed_id'].length.should == 2
    h['feed_id'][0].should == '132'
    h['feed_id'][1].should == '132'
  end

  it 'should handle arrays without [] provided' do
    h = qs_parse('key=1&key[]=2&key%5B%5D=3')
    h['key'].class.should == Array
    h['key'].length.should == 3
    h['key'][0].should == '1'
    h['key'][1].should == '2'
    h['key'][2].should == '3'
  end

  it 'should handle blank items at the beginning and end of the strings' do
    h = qs_parse("&baz=1&bar=2&splat=23&splat[]=42&splat=543&splat%5b%5d=99&splay=http:%2f%2f%3casdf&")
    h.keys.length.should == 4

    h['baz'].should == "1"
    h['bar'].should == "2"
    h['splat'].class.should == Array
    h['splat'].length.should == 4
    h['splat'][0].should == "23"
    h['splat'][1].should == "42"
    h['splat'][2].should == "543"
    h['splat'][3].should == "99"
    h['splay'].should == 'http://<asdf'
  end

  it 'should handle UTF-8 values' do
    h = qs_parse("url%5B%5D=http%3A%2F%2Fwattf.com%2Fwp%2F2008%2F12%2F03%2Fmichael-nielsen-lectures-on-the-google-technology-stack%2F&feed_id%5B%5D=2e2b55b3058696ccbe633e7241d53b16&url%5B%5D=http%3A%2F%2Fjamesgolick.com%2F2008%2F10%2F27%2Foff-topic-caf%C3%A9-myriade&feed_id%5B%5D=0381dd0545852d28d82ad7d0befbfd92")
    h.keys.length.should == 2
    h['url'].class.should == Array
    h['url'].length.should == 2
    h['url'][0].should == 'http://wattf.com/wp/2008/12/03/michael-nielsen-lectures-on-the-google-technology-stack/'
    h['url'][1].should == 'http://jamesgolick.com/2008/10/27/off-topic-café-myriade'

    h['feed_id'].class.should == Array
    h['feed_id'].length.should == 2
    h['feed_id'][0].should == '2e2b55b3058696ccbe633e7241d53b16'
    h['feed_id'][1].should == '0381dd0545852d28d82ad7d0befbfd92'
  end
end