import 'package:browser_html_bookmarks_to_json/src/converter.dart';

void main(List<String> args) {
  final converter = HtmlBookmarksToJson();

  print(
    converter.convert('''
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self'; script-src 'none'; img-src data: *; object-src 'none'"></meta>
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks Menu</H1>

<DL><p>
    <DT><H3 ADD_DATE="1682041911" LAST_MODIFIED="1734309600" PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
    <DL><p>
        <DT><H3 ADD_DATE="1610017123" LAST_MODIFIED="1683163110">LoFi Beats</H3>
        <DL><p>
            <DT><H3 ADD_DATE="1624159637" LAST_MODIFIED="1624159646">Code LoFi</H3>
            <DL><p>
                <DT><A HREF="https://www.youtube.com/watch?v=bmVKaAV_7-A" ADD_DATE="1610017114" LAST_MODIFIED="1624159646" ICON_URI="fake-favicon-uri:https://www.youtube.com/watch?v=bmVKaAV_7-A" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAdklEQVQ4jc2SURHAIAxDI6ESkIAEJCABCZOAJCQgBSfZD/3ZDTbox5a7fEHeXdsAvxEBIRC688D6LtdwIsBFJw37jbDag0A0ABL6bPcfWiNDmAHyHKAqhXTOAKh1E9AaGePjCOMlirxaou2M5iINqnxwpcqf6gRg3lq818aBPAAAAABJRU5ErkJggg==">chill lofi beats to code/relax to - YouTube</A>
            </DL><p>
            <DT><H3 ADD_DATE="1626750141" LAST_MODIFIED="1628702176">Músicas</H3>
            <DL><p>
                <DT><A HREF="https://www.youtube.com/watch?v=jkIITy4_L9s" ADD_DATE="1626750148" LAST_MODIFIED="1626750158" ICON_URI="fake-favicon-uri:https://www.youtube.com/watch?v=jkIITy4_L9s" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAdklEQVQ4jc2SURHAIAxDI6ESkIAEJCABCZOAJCQgBSfZD/3ZDTbox5a7fEHeXdsAvxEBIRC688D6LtdwIsBFJw37jbDag0A0ABL6bPcfWiNDmAHyHKAqhXTOAKh1E9AaGePjCOMlirxaou2M5iINqnxwpcqf6gRg3lq818aBPAAAAABJRU5ErkJggg==">(388) 【泣ける曲】涙が止まらないほど泣ける歌 | 感動する歌 泣ける歌 メドレー Vol.02 - YouTube</A>
            </DL><p>
            <DT><H3 ADD_DATE="1610017123" LAST_MODIFIED="1683163110">LoFi Beats</H3>
            <DL><p>
                <DT><H3 ADD_DATE="1624159637" LAST_MODIFIED="1624159646">Code LoFi</H3>
                <DL><p>
                    <DT><A HREF="https://www.youtube.com/watch?v=bmVKaAV_7-A" ADD_DATE="1610017114" LAST_MODIFIED="1624159646" ICON_URI="fake-favicon-uri:https://www.youtube.com/watch?v=bmVKaAV_7-A" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAdklEQVQ4jc2SURHAIAxDI6ESkIAEJCABCZOAJCQgBSfZD/3ZDTbox5a7fEHeXdsAvxEBIRC688D6LtdwIsBFJw37jbDag0A0ABL6bPcfWiNDmAHyHKAqhXTOAKh1E9AaGePjCOMlirxaou2M5iINqnxwpcqf6gRg3lq818aBPAAAAABJRU5ErkJggg==">chill lofi beats to code/relax to - YouTube</A>
                </DL><p>
        </DL><p>
        <DT><A HREF="https://backloggd.com/u/cherrylipy/lists/" ADD_DATE="1727920665" LAST_MODIFIED="1727920688">Backloggd - cherrylipy</A>
    </DL><p>
</DL>

'''),
  );
}
