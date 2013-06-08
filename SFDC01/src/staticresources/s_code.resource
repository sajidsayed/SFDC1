/* SiteCatalyst code version: H.21.1.
Copyright 1997-2008 Omniture, Inc. More info available at
http://www.omniture.com */
/************************ ADDITIONAL FEATURES ************************
     Plugins
*/

var s_account="emc-emccom"

var s=s_gi(s_account)

/************************** CONFIG SECTION **************************/

/* You may add or alter any code config here. */



s.charSet="ISO-8859-1"

s.dynamicAccountSelection=true

s.dynamicAccountList="emc-lithuania=lithuania.emc.com;emc-emc-latvia=latvia.emc.com;emc-estonia=estonia.emc.com;emc-slovakia=slovakia.emc.com;emc-slovenia=slovenia.emc.com;emc-argentina=argentina.emc.com;emc-australia=australia.emc.com;emc-austria=austria.emc.com;emc-belgium=belgium.emc.com;emc-brazil=brazil.emc.com;emc-canada=canada.emc.com;emc-chile=chile.emc.com;emc-china=china.emc.com;emc-colombia=colombia.emc.com;emc-czech=czech.emc.com;emc-denmark=denmark.emc.com;emc-venezuela=venezuela.emc.com;emc-finland=finland.emc.com;emc-france=france.emc.com;emc-germany=germany.emc.com;emc-greece=greece.emc.com;emc-hk=hk.emc.com;emc-hungary=hungary.emc.com;emc-india=india.emc.com;emc-israel=israel.emc.com;emc-italy=italy.emc.com;emc-japan=japan.emc.com;emc-korea=korea.emc.com;emc-mexico=mexico.emc.com;emc-middleeast=middle-east.emc.com;emc-netherlands=netherlands.emc.com;emc-norway=norway.emc.com;emc-peru=peru.emc.com;emc-poland=poland.emc.com;emc-portugal=portugal.emc.com;emc-puertorico=puertorico.emc.com;emc-russia=russia.emc.com;emc-singapore=singapore.emc.com;emc-singapore=southasia.emc.com;emc-southafrica=southafrica.emc.com;emc-spain=spain.emc.com;emc-suisse=suisse.emc.com;emc-sweden=sweden.emc.com;emc-switzerland=switzerland.emc.com;emc-taiwan=taiwan.emc.com;emc-turkey=turkey.emc.com;emc-uk=uk.emc.com;emc-indonesia=indonesia.emc.com;emc-thailand=thailand.emc.com;emc-malaysia=malaysia.emc.com;emc-philippines=philippines.emc.com;emc-ukraine=ukraine.emc.com;emc-luxembourg=luxembourg.emc.com;emc-dev2008=.isus.emc.com;emc-emccom=."

/************************** CONFIG SECTION **************************/
/* You may add or alter any code config here. */
/* Conversion Config */
s.currencyCode="USD"
/* Link Tracking Config */
s.trackDownloadLinks=true
s.trackExternalLinks=true
s.trackInlineStats=true
s.linkDownloadFileTypes="exe,zip,wav,mp3,mov,mpg,avi,wmv,pdf,doc,docx,xls,xlsx,ppt,pptx"
s.linkInternalFilters="javascript:,info.emc.com,speed-page/index.htm#"
s.linkLeaveQueryString=false
s.linkTrackVars="None"
s.linkTrackEvents="None"

/* Form Analysis Config (should be above doPlugins section) */
s.formList=""
s.trackFormList=false
s.trackPageName=true
s.useCommerce=false
s.varUsed="prop11"
s.eventList=""

/* Page Name Plugin Config */
s.siteID=""            // leftmost value in pagename
s.defaultPage="index.htm"       // filename to add when none exists
s.queryVarsList=""     // query parameters to keep
s.pathExcludeDelim=";" // portion of the path to exclude
s.pathConcatDelim="/"   // page name component separator
s.pathExcludeList=""   // elements to exclude from the path

/* Plugin Config */
s.usePlugins=true
function s_doPlugins(s) {
	/* Add calls to plugins here */
		
	/*Page Name Plugin*/
	if(!s.pageType && !s.pageName)
	 s.pageName=s.getPageName();
	
	/* Logged In Status Pathing Variables */
  if(s.pageName && s.prop7 == 'Logged In') s.prop8 = s.pageName;
  if(s.pageName && s.prop7 == 'Logged Out') s.prop9 = s.pageName;
  
  /* New/Repeat Status and Pathing Variables */
  s.prop12=s.eVar12=s.getNewRepeat();
  if(s.pageName && s.prop12 == 'New') s.prop13 = s.pageName;
  if(s.pageName && s.prop12 == 'Repeat') s.prop14 = s.pageName;
    
  /* Set Time Parting Variables */
  var currentDate = new Date()
  var year = currentDate.getFullYear()
  s.prop17=s.eVar17=s.getTimeParting('h','-5',year); // Set hour 
  s.prop18=s.eVar18=s.getTimeParting('d','-5',year); // Set day
  s.prop19=s.eVar19=s.getTimeParting('w','-5',year); // Set Weekend / Weekday


  /* External Campaign Tracking */

  if(!s.campaign) s.campaign=s.getQueryParam('CMP');//Set campaign here if not set in page already.
  s.campaign=s.getValOnce(s.campaign.toLowerCase(),'s_campaign',0);

  /*enabling campaign pathing*/

  if(s.campaign)
{  
  s.prop50=s.campaign+ ':' +s.pageName;
  s.eVar35=s.prop50;
   
}

  /* Internal Campaign Tracking */
  if(!s.eVar5)
  {
    var pageReferrer=document.referrer;
    var localCheck=pageReferrer.indexOf('emc.com');
    if(localCheck!==-1)
    {
    s.eVar5=s.getQueryParam('intcmp,pid');//Set internal campaign here if not set in page already.
    s.eVar5=s.getValOnce(s.eVar5,'s_evar5',0);
    }
  }


  /*********************
   *prop6 is search term
   *evar6 is search term
   *event2 is searches
  *********************/
  if(s.prop6){
    s.eVar6=s.prop6=s.prop6.toLowerCase();
    var t_search=s.getValOnce(s.eVar6,'ev6',0);
    if(t_search) {
      if(s.events)
        s.events=s.apl(s.events,"event2",",",2)
      else
        s.events="event2"
    }
  }
  
  /* Copy props to eVars */
  if(s.prop1&&!s.eVar1) s.eVar1=s.prop1;
  if(s.prop2&&!s.eVar2) s.eVar2=s.prop2;
  if(s.prop3&&!s.eVar3) s.eVar3=s.prop3;
  if(s.prop4&&!s.eVar4) s.eVar4=s.prop4;


	/* Download handler */

	var url=s.downloadLinkHandler('pdf,ppt,doc'); 
	if(url)
       {	
        s.linkTrackVars='eVar8,prop35,prop36,prop38,eVar39,eVar40,eVar42,events,prop21,eVar21,eVar20';
        s.linkTrackEvents="event10";
	    s.events="event10";
        
        var xstart = url.indexOf(".emc.com")+9;
	    var xend = url.length;
	    var awebcurl = url.substring(xstart,xend);
        s.eVar8=awebcurl+"<>"+s.pageName;
        
        
        s.prop35=awebcurl;
        s.eVar39=s.prop35;
        s.prop36=s.pageName;
        s.eVar40=s.prop36;
   
        var getType=awebcurl.split("/");
        var getTypeArray=getType[1];
        if (getTypeArray.indexOf("hardware")==0 || getTypeArray.indexOf("software")==0)
        {
         var getTypeArray2=getType[2];

         s.prop38=getTypeArray2;
         s.eVar42=s.prop38;
        }else
        {
         s.prop38=getTypeArray;
         s.eVar42=s.prop38;
        } 
        
		/* if(typeof(document.getElementById("contentLeftMenu"))!=="undefined")
        {
        var getProductName=document.getElementById("contentLeftMenu").getElementsByTagName("span")[0].innerHTML;
        s.prop37=getProductName;
        s.eVar41=s.prop37;
        } */
		
       } 

  
	/* formAnalysis */
  s.setupFormAnalysis();

/* channelManager v2.2*/
	s.channelManager('cmp,pid,cmpid,cid,rss,nlcid,nlid,baid',':','s_cm','1');





		s.eVar44=s._referrer;

		s.eVar45=s._referringDomain;

		s.eVar46=s._partner;

		s.campaign=s._campaignID;

		s.eVar47=s._campaign;

		s.eVar48=s._keywords;

                //natural search pathing - keyword

                var SEvar=s._channel;
                
                var SEvarNS=SEvar.indexOf('Natural');
                
                
                if(SEvarNS==0)
                {
                  s.prop46=s.eVar48+": "+s.pageName;
                }

		s.eVar49=SEvar;


//s.eVar11=s.getAndPersistValue(s.campaign,'s_getval',30);


}
s.doPlugins=s_doPlugins
/************************** PLUGINS SECTION *************************/
/* You may insert any plugins you wish to use here.                 */


/*
* Plugin: exitLinkHandler 0.5 - identify and report exit links
*/
s.exitLinkHandler=new Function("p",""
+"var s=this,h=s.p_gh(),n='linkInternalFilters',i,t;if(!h||(s.linkTyp"
+"e&&(h||s.linkName)))return '';i=h.indexOf('?');t=s[n];s[n]=p?p:t;h="
+"s.linkLeaveQueryString||i<0?h:h.substring(0,i);if(s.lt(h)=='e')s.li"
+"nkType='e';else h='';s[n]=t;return h;");


/*
 * Plugin: getAndPersistValue 0.3 - get a value on every page
 */
s.getAndPersistValue=new Function("v","c","e",""
+"var s=this,a=new Date;e=e?e:0;a.setTime(a.getTime()+e*86400000);if("
+"v)s.c_w(c,v,e?a:0);return s.c_r(c);");



/*
 * Plugin: getPageName v2.1 - parse URL and return
 */
s.getPageName=new Function("u",""
+"var s=this,v=u?u:''+s.wd.location,x=v.indexOf(':'),y=v.indexOf('/',"
+"x+4),z=v.indexOf('?'),c=s.pathConcatDelim,e=s.pathExcludeDelim,g=s."
+"queryVarsList,d=s.siteID,n=d?d:'',q=z<0?'':v.substring(z+1),p=v.sub"
+"string(y+1,q?z:v.length);z=p.indexOf('#');p=z<0?p:s.fl(p,z);x=e?p.i"
+"ndexOf(e):-1;p=x<0?p:s.fl(p,x);p+=!p||p.charAt(p.length-1)=='/'?s.d"
+"efaultPage:'';y=c?c:'/';while(p){x=p.indexOf('/');x=x<0?p.length:x;"
+"z=s.fl(p,x);if(!s.pt(s.pathExcludeList,',','p_c',z))n+=n?y+z:z;p=p."
+"substring(x+1)}y=c?c:'?';while(g){x=g.indexOf(',');x=x<0?g.length:x"
+";z=s.fl(g,x);z=s.pt(q,'&','p_c',z);if(z){n+=n?y+z:z;y=c?c:'&'}g=g.s"
+"ubstring(x+1)}return n");

/*
 * Plugin: Form Analysis 2.1 (Success, Error, Abandonment)
 */
s.setupFormAnalysis=new Function(""
+"var s=this;if(!s.fa){s.fa=new Object;var f=s.fa;f.ol=s.wd.onload;s."
+"wd.onload=s.faol;f.uc=s.useCommerce;f.vu=s.varUsed;f.vl=f.uc?s.even"
+"tList:'';f.tfl=s.trackFormList;f.fl=s.formList;f.va=new Array('',''"
+",'','')}");
s.sendFormEvent=new Function("t","pn","fn","en",""
+"var s=this,f=s.fa;t=t=='s'?t:'e';f.va[0]=pn;f.va[1]=fn;f.va[3]=t=='"
+"s'?'Success':en;s.fasl(t);f.va[1]='';f.va[3]='';");
s.faol=new Function("e",""
+"var s=s_c_il["+s._in+"],f=s.fa,r=true,fo,fn,i,en,t,tf;if(!e)e=s.wd."
+"event;f.os=new Array;if(f.ol)r=f.ol(e);if(s.d.forms&&s.d.forms.leng"
+"th>0){for(i=s.d.forms.length-1;i>=0;i--){fo=s.d.forms[i];fn=fo.name"
+";tf=f.tfl&&s.pt(f.fl,',','ee',fn)||!f.tfl&&!s.pt(f.fl,',','ee',fn);"
+"if(tf){f.os[fn]=fo.onsubmit;fo.onsubmit=s.faos;f.va[1]=fn;f.va[3]='"
+"No Data Entered';for(en=0;en<fo.elements.length;en++){el=fo.element"
+"s[en];t=el.type;if(t&&t.toUpperCase){t=t.toUpperCase();var md=el.on"
+"mousedown,kd=el.onkeydown,omd=md?md.toString():'',okd=kd?kd.toStrin"
+"g():'';if(omd.indexOf('.fam(')<0&&okd.indexOf('.fam(')<0){el.s_famd"
+"=md;el.s_fakd=kd;el.onmousedown=s.fam;el.onkeydown=s.fam}}}}}f.ul=s"
+".wd.onunload;s.wd.onunload=s.fasl;}return r;");
s.faos=new Function("e",""
+"var s=s_c_il["+s._in+"],f=s.fa,su;if(!e)e=s.wd.event;if(f.vu){s[f.v"
+"u]='';f.va[1]='';f.va[3]='';}su=f.os[this.name];return su?su(e):tru"
+"e;");
s.fasl=new Function("e",""
+"var s=s_c_il["+s._in+"],f=s.fa,a=f.va,l=s.wd.location,ip=s.trackPag"
+"eName,p=s.pageName;if(a[1]!=''&&a[3]!=''){a[0]=!p&&ip?l.host+l.path"
+"name:a[0]?a[0]:p;if(!f.uc&&a[3]!='No Data Entered'){if(e=='e')a[2]="
+"'Error';else if(e=='s')a[2]='Success';else a[2]='Abandon'}else a[2]"
+"='';var tp=ip?a[0]+':':'',t3=e!='s'?':('+a[3]+')':'',ym=!f.uc&&a[3]"
+"!='No Data Entered'?tp+a[1]+':'+a[2]+t3:tp+a[1]+t3,ltv=s.linkTrackV"
+"ars,lte=s.linkTrackEvents,up=s.usePlugins;if(f.uc){s.linkTrackVars="
+"ltv=='None'?f.vu+',events':ltv+',events,'+f.vu;s.linkTrackEvents=lt"
+"e=='None'?f.vl:lte+','+f.vl;f.cnt=-1;if(e=='e')s.events=s.pt(f.vl,'"
+",','fage',2);else if(e=='s')s.events=s.pt(f.vl,',','fage',1);else s"
+".events=s.pt(f.vl,',','fage',0)}else{s.linkTrackVars=ltv=='None'?f."
+"vu:ltv+','+f.vu}s[f.vu]=ym;s.usePlugins=false;var faLink=new Object"
+"();faLink.href='#';s.tl(faLink,'o','Form Analysis');s[f.vu]='';s.us"
+"ePlugins=up}return f.ul&&e!='e'&&e!='s'?f.ul(e):true;");
s.fam=new Function("e",""
+"var s=s_c_il["+s._in+"],f=s.fa;if(!e) e=s.wd.event;var o=s.trackLas"
+"tChanged,et=e.type.toUpperCase(),t=this.type.toUpperCase(),fn=this."
+"form.name,en=this.name,sc=false;if(document.layers){kp=e.which;b=e."
+"which}else{kp=e.keyCode;b=e.button}et=et=='MOUSEDOWN'?1:et=='KEYDOW"
+"N'?2:et;if(f.ce!=en||f.cf!=fn){if(et==1&&b!=2&&'BUTTONSUBMITRESETIM"
+"AGERADIOCHECKBOXSELECT-ONEFILE'.indexOf(t)>-1){f.va[1]=fn;f.va[3]=e"
+"n;sc=true}else if(et==1&&b==2&&'TEXTAREAPASSWORDFILE'.indexOf(t)>-1"
+"){f.va[1]=fn;f.va[3]=en;sc=true}else if(et==2&&kp!=9&&kp!=13){f.va["
+"1]=fn;f.va[3]=en;sc=true}if(sc){nface=en;nfacf=fn}}if(et==1&&this.s"
+"_famd)return this.s_famd(e);if(et==2&&this.s_fakd)return this.s_fak"
+"d(e);");
s.ee=new Function("e","n",""
+"return n&&n.toLowerCase?e.toLowerCase()==n.toLowerCase():false;");
s.fage=new Function("e","a",""
+"var s=this,f=s.fa,x=f.cnt;x=x?x+1:1;f.cnt=x;return x==a?e:'';");

/*
 * Utility Function: p_gh

 */
s.p_gh=new Function(""
+"var s=this;if(!s.eo&&!s.lnk)return '';var o=s.eo?s.eo:s.lnk,y=s.ot("
+"o),n=s.oid(o),x=o.s_oidt;if(s.eo&&o==s.eo){while(o&&!n&&y!='BODY'){"
+"o=o.parentElement?o.parentElement:o.parentNode;if(!o)return '';y=s."
+"ot(o);n=s.oid(o);x=o.s_oidt}}return o.href?o.href:'';");


/*
 * Plugin: downloadLinkHandler 0.5 - identify and report download links
 */
s.downloadLinkHandler=new Function("p",""
+"var s=this,h=s.p_gh(),n='linkDownloadFileTypes',i,t;if(!h||(s.linkT"
+"ype&&(h||s.linkName)))return '';i=h.indexOf('?');t=s[n];s[n]=p?p:t;"
+"if(s.lt(h)=='d')s.linkType='d';else h='';s[n]=t;return h;");

/*
 * Utility Function: p_c
 */
s.p_c=new Function("v","c",""
+"var x=v.indexOf('=');return c.toLowerCase()==v.substring(0,x<0?v.le"
+"ngth:x).toLowerCase()?v:0");

/*
 * Plugin: getTimeParting 1.3 - Set timeparting values based on time zone
 */
s.getTimeParting=new Function("t","z","y",""
+"dc=new Date('1/1/2000');f=15;ne=8;if(dc.getDay()!=6||"
+"dc.getMonth()!=0){return'Data Not Available'}else{;z=parseInt(z);"
+"if(y=='2009'){f=8;ne=1};gmar=new Date('3/1/'+y);dsts=f-gmar.getDay("
+");gnov=new Date('11/1/'+y);dste=ne-gnov.getDay();spr=new Date('3/'"
+"+dsts+'/'+y);fl=new Date('11/'+dste+'/'+y);cd=new Date();"
+"if(cd>spr&&cd<fl){z=z+1}else{z=z};utc=cd.getTime()+(cd.getTimezoneO"
+"ffset()*60000);tz=new Date(utc + (3600000*z));thisy=tz.getFullYear("
+");var days=['Sunday','Monday','Tuesday','Wednesday','Thursday','Fr"
+"iday','Saturday'];if(thisy!=y){return'Data Not Available'}else{;thi"
+"sh=tz.getHours();thismin=tz.getMinutes();thisd=tz.getDay();var dow="
+"days[thisd];var ap='AM';var dt='Weekday';var mint='00';if(thismin>3"
+"0){mint='30'}if(thish>=12){ap='PM';thish=thish-12};if (thish==0){th"
+"ish=12};if(thisd==6||thisd==0){dt='Weekend'};var timestring=thish+'"
+":'+mint+ap;var daystring=dow;var endstring=dt;if(t=='h'){return tim"
+"estring}if(t=='d'){return daystring};if(t=='w'){return en"
+"dstring}}};"
);

/*
 * Plugin: getNewRepeat 1.0 - Return whether user is new or repeat
 */
s.getNewRepeat=new Function(""
+"var s=this,e=new Date(),cval,ct=e.getTime(),y=e.getYear();e.setTime"
+"(ct+30*24*60*60*1000);cval=s.c_r('s_nr');if(cval.length==0){s.c_w("
+"'s_nr',ct,e);return 'New';}if(cval.length!=0&&ct-cval<30*60*1000){s"
+".c_w('s_nr',ct,e);return 'New';}if(cval<1123916400001){e.setTime(cv"
+"al+30*24*60*60*1000);s.c_w('s_nr',ct,e);return 'Repeat';}else retur"
+"n 'Repeat';");

/*
 * Plugin: getQueryParam 2.3
 */
s.getQueryParam=new Function("p","d","u",""
+"var s=this,v='',i,t;d=d?d:'';u=u?u:(s.pageURL?s.pageURL:s.wd.locati"
+"on);if(u=='f')u=s.gtfs().location;while(p){i=p.indexOf(',');i=i<0?p"
+".length:i;t=s.p_gpv(p.substring(0,i),u+'');if(t){t=t.indexOf('#')>-"
+"1?t.substring(0,t.indexOf('#')):t;}if(t)v+=v?d+t:t;p=p.substring(i="
+"=p.length?i:i+1)}return v");
s.p_gpv=new Function("k","u",""
+"var s=this,v='',i=u.indexOf('?'),q;if(k&&i>-1){q=u.substring(i+1);v"
+"=s.pt(q,'&','p_gvf',k)}return v");
s.p_gvf=new Function("t","k",""
+"if(t){var s=this,i=t.indexOf('='),p=i<0?t:t.substring(0,i),v=i<0?'T"
+"rue':t.substring(i+1);if(p.toLowerCase()==k.toLowerCase())return s."
+"epa(v)}return ''");


/*
 * Plugin: getValOnce 0.2 - get a value once per session or number of days
 */
s.getValOnce=new Function("v","c","e",""
+"var s=this,k=s.c_r(c),a=new Date;e=e?e:0;if(v){a.setTime(a.getTime("
+")+e*86400000);s.c_w(c,v,e?a:0);}return v==k?'':v");

/*
* Plugin Utility: apl v1.1
*/
s.apl=new Function("L","v","d","u",""
+"var s=this,m=0;if(!L)L='';if(u){var i,n,a=s.split(L,d);for(i=0;i<a."
+"length;i++){n=a[i];m=m||(u==1?(n==v):(n.toLowerCase()==v.toLowerCas"
+"e()));}}if(!m)L=L?L+d+v:v;return L");

/*
 * Utility Function: split v1.5 - split a string (JS 1.0 compatible)
 */
s.split=new Function("l","d",""
+"var i,x=0,a=new Array;while(l){i=l.indexOf(d);i=i>-1?i:l.length;a[x"
+"++]=l.substring(0,i);l=l.substring(i+d.length);}return a");

/********************************************************************
 *
 * channelManager v2.2
 *
 *******************************************************************/
/*
 * channelManager v2.2 - Tracking External Traffic
 */
s.channelManager=new Function("a","b","c","V",""
+"var s=this,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,t,u,v,w,x,y,z,A,B,C,D,E,F,"
+"G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,W,X,Y;g=s.referrer?s.referrer:documen"
+"t.referrer;g=g.toLowerCase();if(!g){h='1'}i=g.indexOf('?')>-1?g.ind"
+"exOf('?'):g.length;j=g.substring(0,i);k=s.linkInternalFilters.toLow"
+"erCase();k=s.split(k,',');l=k.length;for(m=0;m<l;m++){n=j.indexOf(k"
+"[m])==-1?'':g;if(n)o=n}if(!o&&!h){p=g;q=g.indexOf('//')>-1?g.indexO"
+"f('//')+2:0;r=g.indexOf('/',q)>-1?g.indexOf('/',q):i;t=g.substring("
+"q,r);t=t.toLowerCase();u=t;P='Referrers';v=s.seList+'>'+s._extraSea"
+"rchEngines;if(V=='1'){j=s.repl(j,'oogle','%');j=s.repl(j,'ahoo','^'"
+");g=s.repl(g,'as_q','*');}A=s.split(v,'>');B=A.length;for(C=0;C<B;C"
+"++){D=A[C];D=s.split(D,'|');E=s.split(D[0],',');F=E.length;for(G=0;"
+"G<F;G++){H=j.indexOf(E[G]);if(H>-1){I=s.split(D[1],',');J=I.length;"
+"for(K=0;K<J;K++){L=s.getQueryParam(I[K],'',g);if(L){L=L.toLowerCase"
+"();M=L;if(D[2]){u=D[2];N=D[2]}else{N=t}if(V=='1'){N=s.repl(N,'#',' "
+"- ');g=s.repl(g,'*','as_q');N=s.repl(N,'^','ahoo');N=s.repl(N,'%','"
+"oogle');}}}}}}}O=s.getQueryParam(a,b);if(O){u=O;if(M){P='Paid Searc"
+"h'}else{P='Paid Non-Search';}}if(!O&&M){u=N;P='Natural Search'}f=s."
+"_channelDomain;if(f){k=s.split(f,'>');l=k.length;for(m=0;m<l;m++){Q"
+"=s.split(k[m],'|');R=s.split(Q[1],',');S=R.length;for(T=0;T<S;T++){"
+"W=j.indexOf(R[T]);if(W>-1)P=Q[0]}}}d=s._channelParameter;if(d){k=s."
+"split(d,'>');l=k.length;for(m=0;m<l;m++){Q=s.split(k[m],'|');R=s.sp"
+"lit(Q[1],',');S=R.length;for(T=0;T<S;T++){U=s.getQueryParam(R[T]);i"
+"f(U)P=Q[0]}}}e=s._channelPattern;if(e){k=s.split(e,'>');l=k.length;"
+"for(m=0;m<l;m++){Q=s.split(k[m],'|');R=s.split(Q[1],',');S=R.length"
+";for(T=0;T<S;T++){X=O.indexOf(R[T]);if(X==0)P=Q[0]}}}if(h=='1'&&!O)"
+"{u=P=t=p='Direct Load'}T=M+u+t;U=c?'c':'c_m';if(c!='0'){T=s.getValO"
+"nce(T,U,0);}if(T)M=M?M:'n/a';s._referrer=T&&p?p:'';s._referringDoma"
+"in=T&&t?t:'';s._partner=T&&N?N:'';s._campaignID=T&&O?O:'';s._campai"
+"gn=T&&u?u:'';s._keywords=T&&M?M:'';s._channel=T&&P?P:'';");
/* Top 130 - Grouped */
s.seList="altavista.co,altavista.de|q,r|AltaVista>.aol.,suche.aolsvc"
+".de|q,query|AOL>ask.jp,ask.co|q,ask|Ask>www.baidu.com|wd|Baidu>daum"
+".net,search.daum.net|q|Daum>google.,googlesyndication.com|q,as_q|Go"
+"ogle>icqit.com|q|icq>bing.com|q|Microsoft Bing>myway.com|searchfor|"
+"MyWay.com>naver.com,search.naver.com|query|Naver>netscape.com|query"
+",search|Netscape Search>reference.com|q|Reference.com>seznam|w|Sezn"
+"am.cz>abcsok.no|q|Startsiden>tiscali.it,www.tiscali.co.uk|key,query"
+"|Tiscali>virgilio.it|qs|Virgilio>yahoo.com,yahoo.co.jp|p,va|Yahoo!>"
+"yandex|text|Yandex.ru>search.cnn.com|query|CNN Web Search>search.ea"
+"rthlink.net|q|Earthlink Search>search.comcast.net|q|Comcast Search>"
+"search.rr.com|qs|RoadRunner Search>optimum.net|q|Optimum Search";
/********************************************************************
 *
 * Commented example of how to use this is doPlugins function
 *
 *******************************************************************/
	/* Plugin Example: channelManager v2.2
	s.channelManager('cmpid');
		s.eVar1=s._campaign;
		s.eVar2=s._keywords;
		s.eVar3=s._channel;
	*/

	/* Plugin Example: channelManager v2.2
	s.channelManager('cmpid,cid,rss,nlcid,nlid,baid',':','s_cm','1');
		s.eVar1=s._referrer
		s.eVar2=s._referringDomain
		s.eVar3=s._partner
		s.campaign=s._campaignID
		s.eVar4=s._campaign
		s.eVar5=s._keywords
		s.eVar6=s._channel
	*/

/********************************************************************
 *
 * Plugin parameters - channelManager(a,b,c,V)
 *
 ********************************************************************
	
	a = Campaign/Channel Identifiers. This is a comma separated list of querystring identifiers for campaigns and channels
	b = (optional) Campaign Value Delimiter. Should you use multiple campaign identifiers in the same querystring, the value 
		listed here will be used as the delimiter
	c = (optional) Cookie name/Disable getValOnce.  A cookie is placed on the visitors browser for use in a getValOnce check. 
		In the event that no value is listed, the channelManager will default to 'c_m'.  If you would like to opt out of the 
		getValOnce check, then populate this parameter with the value ?0?. This will result in no getValOnce check, and no 
		cookie being placed on the visitors browser.
	V = (optional) Uncompress. If you would like to uncompress your Search Engine list, then a one '1' needs to be listed 
		here, otherwise the channelManager does not uncompress
*/

/********************************************************************
 *
 * Config variables (should be above doPlugins section)
 *
 ********************************************************************
	s._extraSearchEngines ? Extra Search Engines.  This variable is used to list the additional Search Engine checks, that 
		are not included within the originally deployed list. 
		This list is formatted by listing the domain(s) of the search engine (comma separated if there are multiple), 
		a pipe, the search keyword parameter(s) (comma separated if there are multiple), a pipe, followed by the name of 
		the search engine. The Search engine groups are separated by greater than signs.
		Example: If Microsoft Bing were to change it?s name to Microsoft Zing, then the following would be my 
		s._extraSearchEngines:
		s._extraSearchEngines=?zing.com|q|Microsoft Zing?
	s._channelDomain ? Channels by Referring Domain. This is a list of the channels that are identified by unique patterns, 
		matched within the referrer (i.e. a domain lookup).
		This list is formatted by listing the channel, then a pipe, then the domains (comma separated list) that belong 
		to that channel.  These channels are separated by greater than symbols.
		Example:s._channelDomain="Social Media|facebook.com,twitter.com,digg.com,linkedin.com,myspace.com"
	s._channelParameter ? Channels by querystring parameters. This is a list of the channels that are identified by unique 
		querystring parameters.
		This list is formatted by listing the channel, then a pipe, then the parameters (comma separated list) that 
		belong to that channel.  These channels are separated by greater than symbols.
		Example:s._channelParameter="RSS|rss>Newsletters|nlcid"
	s._channelPattern ? Channels by querystring parameters. This is a list of the channels that are identified by unique 
		patterns that begin a tracking code.  
		This list is formatted by listing the channel, then a pipe, then the patterns (comma separated list) that belong 
		to that channel.  These channels are separated by greater than symbols.
		Example:s._channelPattern="Banner Ads|ba->Newsletters|nl-"
*/

/********************************************************************
 *
 * Plugin Outputs
 *
 ********************************************************************
	s._referrer = The full document.referrer string, including the querysring, for all external sources 
	s._referringDomain = The sub-domain for all external sources 
	s._partner = The search partner for all search entries.
	s._campaignID = The tracking code.
	s._campaign = This is the value typically returned to the campaign variable in a Unified Source VISTA rule deployment.  
		It returns the campaign ID if one is present, if not, then it returns the Partner(search engine) if one is present, 
		if not, then it returns the referring domain. Direct Load is returned for visitors who enter via direct load.
	s._keywords = Search Keywords, if the visitor enters via a search on a search engine.  If no search terms are present, and 
		it is an entry, then ?n/a? is returned
	s._channel = The Marketing Channel. The default channels are : Paid Search, Paid  Non-Search, Natural Search, Referrers, 
		Direct Load.  More channels are added via the channel configuration variables.
*/

/********************************************************************
 *
 * Utility functions that may be shared between plug-ins (name only)
 *
 *******************************************************************/

/* Top 130 */
s.seList="altavista.co|q,r|AltaVista>aol.co.uk,search.aol.co.uk|query"
+"|AOL - United Kingdom>search.aol.com,search.aol.ca|query,q|AOL.com "
+"Search>ask.com,ask.co.uk|ask,q|Ask Jeeves>www.baidu.com|wd|Baidu>da"
+"um.net,search.daum.net|q|Daum>google.co,googlesyndication.com|q,as_"
+"q|Google>google.com.ar|q,as_q|Google - Argentina>google.com.au|q,as"
+"_q|Google - Australia>google.at|q,as_q|Google - Austria>google.com."
+"bh|q,as_q|Google - Bahrain>google.com.bd|q,as_q|Google - Bangladesh"
+">google.be|q,as_q|Google - Belgium>google.com.bo|q,as_q|Google - Bo"
+"livia>google.ba|q,as_q|Google - Bosnia-Hercegovina>google.com.br|q,"
+"as_q|Google - Brasil>google.bg|q,as_q|Google - Bulgaria>google.ca|q"
+",as_q|Google - Canada>google.cl|q,as_q|Google - Chile>google.cn|q,a"
+"s_q|Google - China>google.com.co|q,as_q|Google - Colombia>google.co"
+".cr|q,as_q|Google - Costa Rica>google.hr|q,as_q|Google - Croatia>go"
+"ogle.cz|q,as_q|Google - Czech Republic>google.dk|q,as_q|Google - De"
+"nmark>google.com.do|q,as_q|Google - Dominican Republic>google.com.e"
+"c|q,as_q|Google - Ecuador>google.com.eg|q,as_q|Google - Egypt>googl"
+"e.com.sv|q,as_q|Google - El Salvador>google.ee|q,as_q|Google - Esto"
+"nia>google.fi|q,as_q|Google - Finland>google.fr|q,as_q|Google - Fra"
+"nce>google.de|q,as_q|Google - Germany>google.gr|q,as_q|Google - Gre"
+"ece>google.com.gt|q,as_q|Google - Guatemala>google.hn|q,as_q|Google"
+" - Honduras>google.com.hk|q,as_q|Google - Hong Kong>google.hu|q,as_"
+"q|Google - Hungary>google.co.in|q,as_q|Google - India>google.co.id|"
+"q,as_q|Google - Indonesia>google.ie|q,as_q|Google - Ireland>google."
+"is|q,as_q|Google - Island>google.co.il|q,as_q|Google - Israel>googl"
+"e.it|q,as_q|Google - Italy>google.com.jm|q,as_q|Google - Jamaica>go"
+"ogle.co.jp|q,as_q|Google - Japan>google.jo|q,as_q|Google - Jordan>g"
+"oogle.co.ke|q,as_q|Google - Kenya>google.co.kr|q,as_q|Google - Kore"
+"a>google.lv|q,as_q|Google - Latvia>google.lt|q,as_q|Google - Lithua"
+"nia>google.com.my|q,as_q|Google - Malaysia>google.com.mt|q,as_q|Goo"
+"gle - Malta>google.mu|q,as_q|Google - Mauritius>google.com.mx|q,as_"
+"q|Google - Mexico>google.co.ma|q,as_q|Google - Morocco>google.nl|q,"
+"as_q|Google - Netherlands>google.co.nz|q,as_q|Google - New Zealand>"
+"google.com.ni|q,as_q|Google - Nicaragua>google.com.ng|q,as_q|Google"
+" - Nigeria>google.no|q,as_q|Google - Norway>google.com.pk|q,as_q|Go"
+"ogle - Pakistan>google.com.py|q,as_q|Google - Paraguay>google.com.p"
+"e|q,as_q|Google - Peru>google.com.ph|q,as_q|Google - Philippines>go"
+"ogle.pl|q,as_q|Google - Poland>google.pt|q,as_q|Google - Portugal>g"
+"oogle.com.pr|q,as_q|Google - Puerto Rico>google.com.qa|q,as_q|Googl"
+"e - Qatar>google.ro|q,as_q|Google - Romania>google.ru|q,as_q|Google"
+" - Russia>google.st|q,as_q|Google - Sao Tome and Principe>google.co"
+"m.sa|q,as_q|Google - Saudi Arabia>google.com.sg|q,as_q|Google - Sin"
+"gapore>google.sk|q,as_q|Google - Slovakia>google.si|q,as_q|Google -"
+" Slovenia>google.co.za|q,as_q|Google - South Africa>google.es|q,as_"
+"q|Google - Spain>google.lk|q,as_q|Google - Sri Lanka>google.se|q,as"
+"_q|Google - Sweden>google.ch|q,as_q|Google - Switzerland>google.com"
+".tw|q,as_q|Google - Taiwan>google.co.th|q,as_q|Google - Thailand>go"
+"ogle.bs|q,as_q|Google - The Bahamas>google.tt|q,as_q|Google - Trini"
+"dad and Tobago>google.com.tr|q,as_q|Google - Turkey>google.com.ua|q"
+",as_q|Google - Ukraine>google.ae|q,as_q|Google - United Arab Emirat"
+"es>google.co.uk|q,as_q|Google - United Kingdom>google.com.uy|q,as_q"
+"|Google - Uruguay>google.co.ve|q,as_q|Google - Venezuela>google.com"
+".vn|q,as_q|Google - Viet Nam>google.co.vi|q,as_q|Google - Virgin Is"
+"lands>icqit.com|q|icq>bing.com|q|Microsoft Bing>myway.com|searchfor"
+"|MyWay.com>naver.com,search.naver.com|query|Naver>netscape.com|quer"
+"y,search|Netscape Search>reference.com|q|Reference.com>seznam|w|Sez"
+"nam.cz>abcsok.no|q|Startsiden>tiscali.it|key|Tiscali>virgilio.it|qs"
+"|Virgilio>yahoo.com,search.yahoo.com|p|Yahoo!>ar.yahoo.com,ar.searc"
+"h.yahoo.com|p|Yahoo! - Argentina>au.yahoo.com,au.search.yahoo.com|p"
+"|Yahoo! - Australia>ca.yahoo.com,ca.search.yahoo.com|p|Yahoo! - Can"
+"ada>fr.yahoo.com,fr.search.yahoo.com|p|Yahoo! - France>de.yahoo.com"
+",de.search.yahoo.com|p|Yahoo! - Germany>hk.yahoo.com,hk.search.yaho"
+"o.com|p|Yahoo! - Hong Kong>in.yahoo.com,in.search.yahoo.com|p|Yahoo"
+"! - India>yahoo.co.jp,search.yahoo.co.jp|p,va|Yahoo! - Japan>kr.yah"
+"oo.com,kr.search.yahoo.com|p|Yahoo! - Korea>mx.yahoo.com,mx.search."
+"yahoo.com|p|Yahoo! - Mexico>ph.yahoo.com,ph.search.yahoo.com|p|Yaho"
+"o! - Philippines>sg.yahoo.com,sg.search.yahoo.com|p|Yahoo! - Singap"
+"ore>es.yahoo.com,es.search.yahoo.com|p|Yahoo! - Spain>telemundo.yah"
+"oo.com,espanol.search.yahoo.com|p|Yahoo! - Spanish (US : Telemundo)"
+">tw.yahoo.com,tw.search.yahoo.com|p|Yahoo! - Taiwan>uk.yahoo.com,uk"
+".search.yahoo.com|p|Yahoo! - UK and Ireland>yandex|text|Yandex.ru>s"
+"earch.cnn.com|query|CNN Web Search>search.earthlink.net|q|Earthlink"
+" Search>search.comcast.net|q|Comcast Search>search.rr.com|qs|RoadRu"
+"nner Search>optimum.net|q|Optimum Search";

/* Top 130 - Compressed */
s.seList="altavista.co|q,r|AltaVista>aol.co.uk,search.aol.co.uk|query"
+"|AOL#United Kingdom>search.aol`,search.aol.ca|query,q|AOL.com Searc"
+"h>ask`,ask.co.uk|ask,q|Ask Jeeves>www.baidu`|wd|Baidu>daum.net,sear"
+"ch.daum.net|q|Daum>g%.co,g%syndication`|q,*|G%>g%`.ar|q,*|G%#Argent"
+"ina>g%`.au|q,*|G%#Australia>g%.at|q,*|G%#Austria>g%`.bh|q,*|G%#Bahr"
+"ain>g%`.bd|q,*|G%#Bangladesh>g%.be|q,*|G%#Belgium>g%`.bo|q,*|G%#Bol"
+"ivia>g%.ba|q,*|G%#Bosnia-Hercegovina>g%`.br|q,*|G%#Brasil>g%.bg|q,*"
+"|G%#Bulgaria>g%.ca|q,*|G%#Canada>g%.cl|q,*|G%#Chile>g%.cn|q,*|G%#Ch"
+"ina>g%`.co|q,*|G%#Colombia>g%.co.cr|q,*|G%#Costa Rica>g%.hr|q,*|G%#"
+"Croatia>g%.cz|q,*|G%#Czech Republic>g%.dk|q,*|G%#Denmark>g%`.do|q,*"
+"|G%#Dominican Republic>g%`.ec|q,*|G%#Ecuador>g%`.eg|q,*|G%#Egypt>g%"
+"`.sv|q,*|G%#El Salvador>g%.ee|q,*|G%#Estonia>g%.fi|q,*|G%#Finland>g"
+"%.fr|q,*|G%#France>g%.de|q,*|G%#Germany>g%.gr|q,*|G%#Greece>g%`.gt|"
+"q,*|G%#Guatemala>g%.hn|q,*|G%#Honduras>g%`.hk|q,*|G%#Hong Kong>g%.h"
+"u|q,*|G%#Hungary>g%.co.in|q,*|G%#India>g%.co.id|q,*|G%#Indonesia>g%"
+".ie|q,*|G%#Ireland>g%.is|q,*|G%#Island>g%.co.il|q,*|G%#Israel>g%.it"
+"|q,*|G%#Italy>g%`.jm|q,*|G%#Jamaica>g%.co.jp|q,*|G%#Japan>g%.jo|q,*"
+"|G%#Jordan>g%.co.ke|q,*|G%#Kenya>g%.co.kr|q,*|G%#Korea>g%.lv|q,*|G%"
+"#Latvia>g%.lt|q,*|G%#Lithuania>g%`.my|q,*|G%#Malaysia>g%`.mt|q,*|G%"
+"#Malta>g%.mu|q,*|G%#Mauritius>g%`.mx|q,*|G%#Mexico>g%.co.ma|q,*|G%#"
+"Morocco>g%.nl|q,*|G%#Netherlands>g%.co.nz|q,*|G%#New Zealand>g%`.ni"
+"|q,*|G%#Nicaragua>g%`.ng|q,*|G%#Nigeria>g%.no|q,*|G%#Norway>g%`.pk|"
+"q,*|G%#Pakistan>g%`.py|q,*|G%#Paraguay>g%`.pe|q,*|G%#Peru>g%`.ph|q,"
+"*|G%#Philippines>g%.pl|q,*|G%#Poland>g%.pt|q,*|G%#Portugal>g%`.pr|q"
+",*|G%#Puerto Rico>g%`.qa|q,*|G%#Qatar>g%.ro|q,*|G%#Romania>g%.ru|q,"
+"*|G%#Russia>g%.st|q,*|G%#Sao Tome and Principe>g%`.sa|q,*|G%#Saudi "
+"Arabia>g%`.sg|q,*|G%#Singapore>g%.sk|q,*|G%#Slovakia>g%.si|q,*|G%#S"
+"lovenia>g%.co.za|q,*|G%#South Africa>g%.es|q,*|G%#Spain>g%.lk|q,*|G"
+"%#Sri Lanka>g%.se|q,*|G%#Sweden>g%.ch|q,*|G%#Switzerland>g%`.tw|q,*"
+"|G%#Taiwan>g%.co.th|q,*|G%#Thailand>g%.bs|q,*|G%#The Bahamas>g%.tt|"
+"q,*|G%#Trinidad and Tobago>g%`.tr|q,*|G%#Turkey>g%`.ua|q,*|G%#Ukrai"
+"ne>g%.ae|q,*|G%#United Arab Emirates>g%.co.uk|q,*|G%#United Kingdom"
+">g%`.uy|q,*|G%#Uruguay>g%.co.ve|q,*|G%#Venezuela>g%`.vn|q,*|G%#Viet"
+" Nam>g%.co.vi|q,*|G%#Virgin Islands>icqit`|q|icq>bing`|q|Microsoft "
+"Bing>myway`|searchfor|MyWay.com>naver`,search.naver`|query|Naver>ne"
+"tscape`|query,search|Netscape Search>reference`|q|Reference.com>sez"
+"nam|w|Seznam.cz>abcsok.no|q|Startsiden>tiscali.it|key|Tiscali>virgi"
+"lio.it|qs|Virgilio>y^`,search.y^`|p|Y^!>ar.y^`,ar.search.y^`|p|Y^!#"
+"Argentina>au.y^`,au.search.y^`|p|Y^!#Australia>ca.y^`,ca.search.y^`"
+"|p|Y^!#Canada>fr.y^`,fr.search.y^`|p|Y^!#France>de.y^`,de.search.y^"
+"`|p|Y^!#Germany>hk.y^`,hk.search.y^`|p|Y^!#Hong Kong>in.y^`,in.sear"
+"ch.y^`|p|Y^!#India>y^.co.jp,search.y^.co.jp|p,va|Y^!#Japan>kr.y^`,k"
+"r.search.y^`|p|Y^!#Korea>mx.y^`,mx.search.y^`|p|Y^!#Mexico>ph.y^`,p"
+"h.search.y^`|p|Y^!#Philippines>sg.y^`,sg.search.y^`|p|Y^!#Singapore"
+">es.y^`,es.search.y^`|p|Y^!#Spain>telemundo.y^`,espanol.search.y^`|"
+"p|Y^!#Spanish (US : Telemundo)>tw.y^`,tw.search.y^`|p|Y^!#Taiwan>uk"
+".y^`,uk.search.y^`|p|Y^!#UK and Ireland>yandex|text|Yandex.ru>searc"
+"h.cnn.com|query|CNN Web Search>search.earthlink.net|q|Earthlink Sea"
+"rch>search.comcast.net|q|Comcast Search>search.rr.com|qs|RoadRunner"
+" Search>optimum.net|q|Optimum Search";

/********************************************************************
 *
 * Main Plug-in code (should be in Plug-ins section)
 *
 *******************************************************************/
/*
 * Utility Function: split v1.5 (JS 1.0 compatible)
 */
s.split=new Function("l","d",""
+"var i,x=0,a=new Array;while(l){i=l.indexOf(d);i=i>-1?i:l.length;a[x"
+"++]=l.substring(0,i);l=l.substring(i+d.length);}return a");


/********************************************************************
 *
 * Main Plug-in code (should be in Plug-ins section)
 *
 *******************************************************************/
/*
 * Plugin Utility: Replace v1.0
 */
s.repl=new Function("x","o","n",""
+"var i=x.indexOf(o),l=n.length;while(x&&i>=0){x=x.substring(0,i)+n+x."
+"substring(i+o.length);i=x.indexOf(o,i+l)}return x");


/********************************************************************
 *
 * Main Plug-in code (should be in Plug-ins section)
 *
 *******************************************************************/
/*
 * Plugin: getQueryParam 2.3
 */
s.getQueryParam=new Function("p","d","u",""
+"var s=this,v='',i,t;d=d?d:'';u=u?u:(s.pageURL?s.pageURL:s.wd.locati"
+"on);if(u=='f')u=s.gtfs().location;while(p){i=p.indexOf(',');i=i<0?p"
+".length:i;t=s.p_gpv(p.substring(0,i),u+'');if(t){t=t.indexOf('#')>-"
+"1?t.substring(0,t.indexOf('#')):t;}if(t)v+=v?d+t:t;p=p.substring(i="
+"=p.length?i:i+1)}return v");
s.p_gpv=new Function("k","u",""
+"var s=this,v='',i=u.indexOf('?'),q;if(k&&i>-1){q=u.substring(i+1);v"
+"=s.pt(q,'&','p_gvf',k)}return v");
s.p_gvf=new Function("t","k",""
+"if(t){var s=this,i=t.indexOf('='),p=i<0?t:t.substring(0,i),v=i<0?'T"
+"rue':t.substring(i+1);if(p.toLowerCase()==k.toLowerCase())return s."
+"epa(v)}return ''");


/********************************************************************
 *
 * Main Plug-in code (should be in Plug-ins section)
 *
 *******************************************************************/
/*
 * Plugin: getValOnce_v1.0
 */
s.getValOnce=new Function("v","c","e",""
+"var s=this,a=new Date,v=v?v:v='',c=c?c:c='s_gvo',e=e?e:0,k=s.c_r(c"
+");if(v){a.setTime(a.getTime()+e*86400000);s.c_w(c,v,e?a:0);}return"
+" v==k?'':v");

s.loadModule("Media")
s.Media.autoTrack=false
s.Media.trackWhilePlaying=true
s.Media.trackVars="None"
s.Media.trackEvents="None"

s.loadModule("Survey")
var s_sv_dynamic_root = "survey.122.2o7.net/survey/dynamic"
var s_sv_gather_root = "survey.122.2o7.net/survey/gather"

/* WARNING: Changing any of the below variables will cause drastic
changes to how your visitor data is collected.  Changes should only be
made when instructed to do so by your account manager.*/

s.visitorNamespace="emc"
s.dc=122
s.trackingServer="ecn-analytics-nssl.emc.com"
s.trackingServerSecure="ecn-analytics.emc.com"
s.visitorMigrationKey="4D73E974"
s.visitorMigrationServer="emc.122.2o7.net"


/****************************** MODULES *****************************/
/* Module: Media */
s.m_Media_c="var m=s.m_i('Media');m.cn=function(n){var m=this;return m.s.rep(m.s.rep(m.s.rep(n,\"\\n\",''),\"\\r\",''),'--**--','')};m.open=function(n,l,p,b){var m=this,i=new Object,tm=new Date,a='',"
+"x;n=m.cn(n);l=parseInt(l);if(!l)l=1;if(n&&p){if(!m.l)m.l=new Object;if(m.l[n])m.close(n);if(b&&b.id)a=b.id;for (x in m.l)if(m.l[x]&&m.l[x].a==a)m.close(m.l[x].n);i.n=n;i.l=l;i.p=m.cn(p);i.a=a;i.t=0"
+";i.ts=0;i.s=Math.floor(tm.getTime()/1000);i.lx=0;i.lt=i.s;i.lo=0;i.e='';i.to=-1;m.l[n]=i}};m.close=function(n){this.e(n,0,-1)};m.play=function(n,o){var m=this,i;i=m.e(n,1,o);i.m=new Function('var m"
+"=s_c_il['+m._in+'],i;if(m.l){i=m.l[\"'+m.s.rep(i.n,'\"','\\\\\"')+'\"];if(i){if(i.lx==1)m.e(i.n,3,-1);i.mt=setTimeout(i.m,5000)}}');i.m()};m.stop=function(n,o){this.e(n,2,o)};m.track=function(n){va"
+"r m=this;if (m.trackWhilePlaying) {m.e(n,4,-1)}};m.e=function(n,x,o){var m=this,i,tm=new Date,ts=Math.floor(tm.getTime()/1000),ti=m.trackSeconds,tp=m.trackMilestones,z=new Array,j,d='--**--',t=1,b,"
+"v=m.trackVars,e=m.trackEvents,pe='media',pev3,w=new Object,vo=new Object;n=m.cn(n);i=n&&m.l&&m.l[n]?m.l[n]:0;if(i){w.name=n;w.length=i.l;w.playerName=i.p;if(i.to<0)w.event=\"OPEN\";else w.event=(x="
+"=1?\"PLAY\":(x==2?\"STOP\":(x==3?\"MONITOR\":\"CLOSE\")));w.openTime=new Date();w.openTime.setTime(i.s*1000);if(x>2||(x!=i.lx&&(x!=2||i.lx==1))) {b=\"Media.\"+name;pev3 = m.s.ape(i.n)+d+i.l+d+m.s.a"
+"pe(i.p)+d;if(x){if(o<0&&i.lt>0){o=(ts-i.lt)+i.lo;o=o<i.l?o:i.l-1}o=Math.floor(o);if(x>=2&&i.lo<o){i.t+=o-i.lo;i.ts+=o-i.lo;}if(x<=2){i.e+=(x==1?'S':'E')+o;i.lx=x;}else if(i.lx!=1)m.e(n,1,o);i.lt=ts"
+";i.lo=o;pev3+=i.t+d+i.s+d+(m.trackWhilePlaying&&i.to>=0?'L'+i.to:'')+i.e+(x!=2?(m.trackWhilePlaying?'L':'E')+o:'');if(m.trackWhilePlaying){b=0;pe='m_o';if(x!=4){w.offset=o;w.percent=((w.offset+1)/w"
+".length)*100;w.percent=w.percent>100?100:Math.floor(w.percent);w.timePlayed=i.t;if(m.monitor)m.monitor(m.s,w)}if(i.to<0)pe='m_s';else if(x==4)pe='m_i';else{t=0;v=e='None';ti=ti?parseInt(ti):0;z=tp?"
+"m.s.sp(tp,','):0;if(ti&&i.ts>=ti)t=1;else if(z){if(o<i.to)i.to=o;else{for(j=0;j<z.length;j++){ti=z[j]?parseInt(z[j]):0;if(ti&&((i.to+1)/i.l<ti/100)&&((o+1)/i.l>=ti/100)){t=1;j=z.length}}}}}}}else{m"
+".e(n,2,-1);if(m.trackWhilePlaying){w.offset=i.lo;w.percent=((w.offset+1)/w.length)*100;w.percent=w.percent>100?100:Math.floor(w.percent);w.timePlayed=i.t;if(m.monitor)m.monitor(m.s,w)}m.l[n]=0;if(i"
+".e){pev3+=i.t+d+i.s+d+(m.trackWhilePlaying&&i.to>=0?'L'+i.to:'')+i.e;if(m.trackWhilePlaying){v=e='None';pe='m_o'}else{t=0;m.s.fbr(b)}}else t=0;b=0}if(t){vo.linkTrackVars=v;vo.linkTrackEvents=e;vo.p"
+"e=pe;vo.pev3=pev3;m.s.t(vo,b);if(m.trackWhilePlaying){i.ts=0;i.to=o;i.e=''}}}}return i};m.ae=function(n,l,p,x,o,b){if(n&&p){var m=this;if(!m.l||!m.l[n])m.open(n,l,p,b);m.e(n,x,o)}};m.a=function(o,t"
+"){var m=this,i=o.id?o.id:o.name,n=o.name,p=0,v,c,c1,c2,xc=m.s.h,x,e,f1,f2='s_media_'+m._in+'_oc',f3='s_media_'+m._in+'_t',f4='s_media_'+m._in+'_s',f5='s_media_'+m._in+'_l',f6='s_media_'+m._in+'_m',"
+"f7='s_media_'+m._in+'_c',tcf,w;if(!i){if(!m.c)m.c=0;i='s_media_'+m._in+'_'+m.c;m.c++}if(!o.id)o.id=i;if(!o.name)o.name=n=i;if(!m.ol)m.ol=new Object;if(m.ol[i])return;m.ol[i]=o;if(!xc)xc=m.s.b;tcf=n"
+"ew Function('o','var e,p=0;try{if(o.versionInfo&&o.currentMedia&&o.controls)p=1}catch(e){p=0}return p');p=tcf(o);if(!p){tcf=new Function('o','var e,p=0,t;try{t=o.GetQuickTimeVersion();if(t)p=2}catc"
+"h(e){p=0}return p');p=tcf(o);if(!p){tcf=new Function('o','var e,p=0,t;try{t=o.GetVersionInfo();if(t)p=3}catch(e){p=0}return p');p=tcf(o)}}v=\"var m=s_c_il[\"+m._in+\"],o=m.ol['\"+i+\"']\";if(p==1){"
+"p='Windows Media Player '+o.versionInfo;c1=v+',n,p,l,x=-1,cm,c,mn;if(o){cm=o.currentMedia;c=o.controls;if(cm&&c){mn=cm.name?cm.name:c.URL;l=cm.duration;p=c.currentPosition;n=o.playState;if(n){if(n="
+"=8)x=0;if(n==3)x=1;if(n==1||n==2||n==4||n==5||n==6)x=2;}';c2='if(x>=0)m.ae(mn,l,\"'+p+'\",x,x!=2?p:-1,o)}}';c=c1+c2;if(m.s.isie&&xc){x=m.s.d.createElement('script');x.language='jscript';x.type='tex"
+"t/javascript';x.htmlFor=i;x.event='PlayStateChange(NewState)';x.defer=true;x.text=c;xc.appendChild(x);o[f6]=new Function(c1+'if(n==3){x=3;'+c2+'}setTimeout(o.'+f6+',5000)');o[f6]()}}if(p==2){p='Qui"
+"ckTime Player '+(o.GetIsQuickTimeRegistered()?'Pro ':'')+o.GetQuickTimeVersion();f1=f2;c=v+',n,x,t,l,p,p2,mn;if(o){mn=o.GetMovieName()?o.GetMovieName():o.GetURL();n=o.GetRate();t=o.GetTimeScale();l"
+"=o.GetDuration()/t;p=o.GetTime()/t;p2=o.'+f5+';if(n!=o.'+f4+'||p<p2||p-p2>5){x=2;if(n!=0)x=1;else if(p>=l)x=0;if(p<p2||p-p2>5)m.ae(mn,l,\"'+p+'\",2,p2,o);m.ae(mn,l,\"'+p+'\",x,x!=2?p:-1,o)}if(n>0&&"
+"o.'+f7+'>=10){m.ae(mn,l,\"'+p+'\",3,p,o);o.'+f7+'=0}o.'+f7+'++;o.'+f4+'=n;o.'+f5+'=p;setTimeout(\"'+v+';o.'+f2+'(0,0)\",500)}';o[f1]=new Function('a','b',c);o[f4]=-1;o[f7]=0;o[f1](0,0)}if(p==3){p='"
+"RealPlayer '+o.GetVersionInfo();f1=n+'_OnPlayStateChange';c1=v+',n,x=-1,l,p,mn;if(o){mn=o.GetTitle()?o.GetTitle():o.GetSource();n=o.GetPlayState();l=o.GetLength()/1000;p=o.GetPosition()/1000;if(n!="
+"o.'+f4+'){if(n==3)x=1;if(n==0||n==2||n==4||n==5)x=2;if(n==0&&(p>=l||p==0))x=0;if(x>=0)m.ae(mn,l,\"'+p+'\",x,x!=2?p:-1,o)}if(n==3&&(o.'+f7+'>=10||!o.'+f3+')){m.ae(mn,l,\"'+p+'\",3,p,o);o.'+f7+'=0}o."
+"'+f7+'++;o.'+f4+'=n;';c2='if(o.'+f2+')o.'+f2+'(o,n)}';if(m.s.wd[f1])o[f2]=m.s.wd[f1];m.s.wd[f1]=new Function('a','b',c1+c2);o[f1]=new Function('a','b',c1+'setTimeout(\"'+v+';o.'+f1+'(0,0)\",o.'+f3+"
+"'?500:5000);'+c2);o[f4]=-1;if(m.s.isie)o[f3]=1;o[f7]=0;o[f1](0,0)}};m.as=new Function('e','var m=s_c_il['+m._in+'],l,n;if(m.autoTrack&&m.s.d.getElementsByTagName){l=m.s.d.getElementsByTagName(m.s.i"
+"sie?\"OBJECT\":\"EMBED\");if(l)for(n=0;n<l.length;n++)m.a(l[n]);}');if(s.wd.attachEvent)s.wd.attachEvent('onload',m.as);else if(s.wd.addEventListener)s.wd.addEventListener('load',m.as,false)";
s.m_i("Media");
/* Module: Survey */
s.m_Survey_c="var m=s.m_i(\"Survey\");m.launch=function(i,e,c,o,f){this._boot();var m=this,g=window.s_sv_globals||{},l,j;if(g.unloaded||m._blocked())return 0;i=i&&i.constructor&&i.constructor==Array?"
+"i:[i];l=g.manualTriggers;for(j=0;j<i.length;++j)l[l.length]={l:m._suites,i:i[j],e:e||0,c:c||0,o:o||0,f:f||0};m._execute();return 1;};m._t=function(){this._boot();var m=this,s=m.s,g=window.s_sv_glob"
+"als||{},l;if(m._blocked())return;l=g.pageImpressions;l[l.length]={l:m._suites,n:s.pageName||\"\",u:s.pageURL||\"\",r:s.referrer||\"\",c:s.campaign||\"\"};m._execute();};m._rr=function(){var g=windo"
+"w.s_sv_globals||{},f=g.onScQueueEmpty||0;if(f)f();};m._blocked=function(){var m=this,g=window.s_sv_globals||{};return !m._booted||g.stop||!g.pending&&!g.triggerRequested;};m._execute=function(){if("
+"s_sv_globals.execute)setTimeout(\"s_sv_globals.execute();\",0);};m._boot=function(){var m=this,s=m.s,w=window,g,c,d=s.dc,e=s.visitorNamespace,n=navigator.appName.toLowerCase(),a=navigator.userAgent"
+",v=navigator.appVersion,h,i,j,k,l,b;if(w.s_sv_globals)return;if(!((b=v.match(/AppleWebKit\\/([0-9]+)/))?521<b[1]:n==\"netscape\"?a.match(/gecko\\//i):(b=a.match(/opera[ \\/]?([0-9]+).[0-9]+/i))?7<b"
+"[1]:n==\"microsoft internet explorer\"&&!v.match(/macintosh/i)&&(b=v.match(/msie ([0-9]+).([0-9]+)/i))&&(5<b[1]||b[1]==5&&4<b[2])))return;g=w.s_sv_globals={};g.module=m;g.pending=0;g.incomingLists="
+"[];g.pageImpressions=[];g.manualTriggers=[];e=\"survey\";c=g.config={};m._param(c,\"dynamic_root\",(e?e+\".\":\"\")+d+\".2o7.net/survey/dynamic\");m._param(c,\"gather_root\",(e?e+\".\":\"\")+d+\".2"
+"o7.net/survey/gather\");g.url=location.protocol+\"//\"+c.dynamic_root;g.gatherUrl=location.protocol+\"//\"+c.gather_root;g.dataCenter=d;g.onListLoaded=new Function(\"r\",\"b\",\"d\",\"i\",\"l\",\"s"
+"_sv_globals.module._loaded(r,b,d,i,l);\");m._suites=(m.suites||s.un).toLowerCase().split(\",\");l=m._suites;b={};for(j=0;j<l.length;++j){i=l[j];if(i&&!b[i]){h=i.length;for(k=0;k<i.length;++k)h=(h&0"
+"x03ffffff)<<5^h>>26^i.charCodeAt(k);b[i]={url:g.url+\"/suites/\"+(h%251+100)+\"/\"+encodeURIComponent(i.replace(/\\|/,\"||\").replace(/\\//,\"|-\"))};++g.pending;}}g.suites=b;setTimeout(\"s_sv_glob"
+"als.module._load();\",0);m._booted=1;};m._param=function(c,n,v){var p=\"s_sv_\",w=window,u=\"undefined\";if(typeof c[n]==u)c[n]=typeof w[p+n]==u?v:w[p+n];};m._load=function(){var m=this,g=s_sv_glob"
+"als,q=g.suites,r,i,n=\"s_sv_sid\",b=m.s.c_r(n);if(!b){b=parseInt((new Date()).getTime()*Math.random());m.s.c_w(n,b);}for(i in q){r=q[i];if(!r.requested){r.requested=1;m._script(r.url+\"/list.js?\"+"
+"b);}}};m._loaded=function(r,b,d,i,l){var m=this,g=s_sv_globals,n=g.incomingLists;--g.pending;if(!g.commonRevision){g.bulkRevision=b;g.commonRevision=r;g.commonUrl=g.url+\"/common/\"+b;}else if(g.co"
+"mmonRevision!=r)return;if(!l.length)return;n[n.length]={r:i,l:l};if(g.execute)g.execute();else if(!g.triggerRequested){g.triggerRequested=1;m._script(g.commonUrl+\"/trigger.js\");}};m._script=funct"
+"ion(u){var d=document,e=d.createElement(\"script\");e.type=\"text/javascript\";e.src=u;d.getElementsByTagName(\"head\")[0].appendChild(e);};if(m.onLoad)m.onLoad(s,m)";
s.m_i("Survey");

/************* DO NOT ALTER ANYTHING BELOW THIS LINE ! **************/
var s_code='',s_objectID;function s_gi(un,pg,ss){var c="s._c='s_c';s.wd=window;if(!s.wd.s_c_in){s.wd.s_c_il=new Array;s.wd.s_c_in=0;}s._il=s.wd.s_c_il;s._in=s.wd.s_c_in;s._il[s._in]=s;s.wd.s_c_in++;s"
+".an=s_an;s.cls=function(x,c){var i,y='';if(!c)c=this.an;for(i=0;i<x.length;i++){n=x.substring(i,i+1);if(c.indexOf(n)>=0)y+=n}return y};s.fl=function(x,l){return x?(''+x).substring(0,l):x};s.co=func"
+"tion(o){if(!o)return o;var n=new Object,x;for(x in o)if(x.indexOf('select')<0&&x.indexOf('filter')<0)n[x]=o[x];return n};s.num=function(x){x=''+x;for(var p=0;p<x.length;p++)if(('0123456789').indexO"
+"f(x.substring(p,p+1))<0)return 0;return 1};s.rep=s_rep;s.sp=s_sp;s.jn=s_jn;s.ape=function(x){var s=this,h='0123456789ABCDEF',i,c=s.charSet,n,l,e,y='';c=c?c.toUpperCase():'';if(x){x=''+x;if(s.em==3)"
+"return encodeURIComponent(x);else if(c=='AUTO'&&('').charCodeAt){for(i=0;i<x.length;i++){c=x.substring(i,i+1);n=x.charCodeAt(i);if(n>127){l=0;e='';while(n||l<4){e=h.substring(n%16,n%16+1)+e;n=(n-n%"
+"16)/16;l++}y+='%u'+e}else if(c=='+')y+='%2B';else y+=escape(c)}return y}else{x=s.rep(escape(''+x),'+','%2B');if(c&&s.em==1&&x.indexOf('%u')<0&&x.indexOf('%U')<0){i=x.indexOf('%');while(i>=0){i++;if"
+"(h.substring(8).indexOf(x.substring(i,i+1).toUpperCase())>=0)return x.substring(0,i)+'u00'+x.substring(i);i=x.indexOf('%',i)}}}}return x};s.epa=function(x){var s=this;if(x){x=''+x;return s.em==3?de"
+"codeURIComponent(x):unescape(s.rep(x,'+',' '))}return x};s.pt=function(x,d,f,a){var s=this,t=x,z=0,y,r;while(t){y=t.indexOf(d);y=y<0?t.length:y;t=t.substring(0,y);r=s[f](t,a);if(r)return r;z+=y+d.l"
+"ength;t=x.substring(z,x.length);t=z<x.length?t:''}return ''};s.isf=function(t,a){var c=a.indexOf(':');if(c>=0)a=a.substring(0,c);if(t.substring(0,2)=='s_')t=t.substring(2);return (t!=''&&t==a)};s.f"
+"sf=function(t,a){var s=this;if(s.pt(a,',','isf',t))s.fsg+=(s.fsg!=''?',':'')+t;return 0};s.fs=function(x,f){var s=this;s.fsg='';s.pt(x,',','fsf',f);return s.fsg};s.si=function(){var s=this,i,k,v,c="
+"s_gi+'var s=s_gi(\"'+s.oun+'\");s.sa(\"'+s.un+'\");';for(i=0;i<s.va_g.length;i++){k=s.va_g[i];v=s[k];if(v!=undefined){if(typeof(v)=='string')c+='s.'+k+'=\"'+s_fe(v)+'\";';else c+='s.'+k+'='+v+';'}}"
+"c+=\"s.lnk=s.eo=s.linkName=s.linkType=s.wd.s_objectID=s.ppu=s.pe=s.pev1=s.pev2=s.pev3='';\";return c};s.c_d='';s.c_gdf=function(t,a){var s=this;if(!s.num(t))return 1;return 0};s.c_gd=function(){var"
+" s=this,d=s.wd.location.hostname,n=s.fpCookieDomainPeriods,p;if(!n)n=s.cookieDomainPeriods;if(d&&!s.c_d){n=n?parseInt(n):2;n=n>2?n:2;p=d.lastIndexOf('.');if(p>=0){while(p>=0&&n>1){p=d.lastIndexOf('"
+".',p-1);n--}s.c_d=p>0&&s.pt(d,'.','c_gdf',0)?d.substring(p):d}}return s.c_d};s.c_r=function(k){var s=this;k=s.ape(k);var c=' '+s.d.cookie,i=c.indexOf(' '+k+'='),e=i<0?i:c.indexOf(';',i),v=i<0?'':s."
+"epa(c.substring(i+2+k.length,e<0?c.length:e));return v!='[[B]]'?v:''};s.c_w=function(k,v,e){var s=this,d=s.c_gd(),l=s.cookieLifetime,t;v=''+v;l=l?(''+l).toUpperCase():'';if(e&&l!='SESSION'&&l!='NON"
+"E'){t=(v!=''?parseInt(l?l:0):-60);if(t){e=new Date;e.setTime(e.getTime()+(t*1000))}}if(k&&l!='NONE'){s.d.cookie=k+'='+s.ape(v!=''?v:'[[B]]')+'; path=/;'+(e&&l!='SESSION'?' expires='+e.toGMTString()"
+"+';':'')+(d?' domain='+d+';':'');return s.c_r(k)==v}return 0};s.eh=function(o,e,r,f){var s=this,b='s_'+e+'_'+s._in,n=-1,l,i,x;if(!s.ehl)s.ehl=new Array;l=s.ehl;for(i=0;i<l.length&&n<0;i++){if(l[i]."
+"o==o&&l[i].e==e)n=i}if(n<0){n=i;l[n]=new Object}x=l[n];x.o=o;x.e=e;f=r?x.b:f;if(r||f){x.b=r?0:o[e];x.o[e]=f}if(x.b){x.o[b]=x.b;return b}return 0};s.cet=function(f,a,t,o,b){var s=this,r,tcf;if(s.apv"
+">=5&&(!s.isopera||s.apv>=7)){tcf=new Function('s','f','a','t','var e,r;try{r=s[f](a)}catch(e){r=s[t](e)}return r');r=tcf(s,f,a,t)}else{if(s.ismac&&s.u.indexOf('MSIE 4')>=0)r=s[b](a);else{s.eh(s.wd,"
+"'onerror',0,o);r=s[f](a);s.eh(s.wd,'onerror',1)}}return r};s.gtfset=function(e){var s=this;return s.tfs};s.gtfsoe=new Function('e','var s=s_c_il['+s._in+'],c;s.eh(window,\"onerror\",1);s.etfs=1;c=s"
+".t();if(c)s.d.write(c);s.etfs=0;return true');s.gtfsfb=function(a){return window};s.gtfsf=function(w){var s=this,p=w.parent,l=w.location;s.tfs=w;if(p&&p.location!=l&&p.location.host==l.host){s.tfs="
+"p;return s.gtfsf(s.tfs)}return s.tfs};s.gtfs=function(){var s=this;if(!s.tfs){s.tfs=s.wd;if(!s.etfs)s.tfs=s.cet('gtfsf',s.tfs,'gtfset',s.gtfsoe,'gtfsfb')}return s.tfs};s.mrq=function(u){var s=this,"
+"l=s.rl[u],n,r;s.rl[u]=0;if(l)for(n=0;n<l.length;n++){r=l[n];s.mr(0,0,r.r,0,r.t,r.u)}};s.br=function(id,rs){var s=this;if(s.disableBufferedRequests||!s.c_w('s_br',rs))s.brl=rs};s.flushBufferedReques"
+"ts=function(){this.fbr(0)};s.fbr=function(id){var s=this,br=s.c_r('s_br');if(!br)br=s.brl;if(br){if(!s.disableBufferedRequests)s.c_w('s_br','');s.mr(0,0,br)}s.brl=0};s.mr=function(sess,q,rs,id,ta,u"
+"){var s=this,dc=s.dc,t1=s.trackingServer,t2=s.trackingServerSecure,tb=s.trackingServerBase,p='.sc',ns=s.visitorNamespace,un=s.cls(u?u:(ns?ns:s.fun)),r=new Object,l,imn='s_i_'+(un),im,b,e;if(!rs){if"
+"(t1){if(t2&&s.ssl)t1=t2}else{if(!tb)tb='2o7.net';if(dc)dc=(''+dc).toLowerCase();else dc='d1';if(tb=='2o7.net'){if(dc=='d1')dc='112';else if(dc=='d2')dc='122';p=''}t1=un+'.'+dc+'.'+p+tb}rs='http'+(s"
+".ssl?'s':'')+'://'+t1+'/b/ss/'+s.un+'/'+(s.mobile?'5.1':'1')+'/H.21.1/'+sess+'?AQB=1&ndh=1'+(q?q:'')+'&AQE=1';if(s.isie&&!s.ismac){if(s.apv>5.5)rs=s.fl(rs,4095);else rs=s.fl(rs,2047)}if(id){s.br(id"
+",rs);return}}if(s.d.images&&s.apv>=3&&(!s.isopera||s.apv>=7)&&(s.ns6<0||s.apv>=6.1)){if(!s.rc)s.rc=new Object;if(!s.rc[un]){s.rc[un]=1;if(!s.rl)s.rl=new Object;s.rl[un]=new Array;setTimeout('if(win"
+"dow.s_c_il)window.s_c_il['+s._in+'].mrq(\"'+un+'\")',750)}else{l=s.rl[un];if(l){r.t=ta;r.u=un;r.r=rs;l[l.length]=r;return ''}imn+='_'+s.rc[un];s.rc[un]++}im=s.wd[imn];if(!im)im=s.wd[imn]=new Image;"
+"im.s_l=0;im.onload=new Function('e','this.s_l=1;var wd=window,s;if(wd.s_c_il){s=wd.s_c_il['+s._in+'];s.mrq(\"'+un+'\");s.nrs--;if(!s.nrs)s.m_m(\"rr\")}');if(!s.nrs){s.nrs=1;s.m_m('rs')}else s.nrs++"
+";im.src=rs;if(rs.indexOf('&pe=')>=0&&(!ta||ta=='_self'||ta=='_top'||(s.wd.name&&ta==s.wd.name))){b=e=new Date;while(!im.s_l&&e.getTime()-b.getTime()<500)e=new Date}return ''}return '<im'+'g sr'+'c="
+"\"'+rs+'\" width=1 height=1 border=0 alt=\"\">'};s.gg=function(v){var s=this;if(!s.wd['s_'+v])s.wd['s_'+v]='';return s.wd['s_'+v]};s.glf=function(t,a){if(t.substring(0,2)=='s_')t=t.substring(2);var"
+" s=this,v=s.gg(t);if(v)s[t]=v};s.gl=function(v){var s=this;if(s.pg)s.pt(v,',','glf',0)};s.rf=function(x){var s=this,y,i,j,h,l,a,b='',c='',t;if(x){y=''+x;i=y.indexOf('?');if(i>0){a=y.substring(i+1);"
+"y=y.substring(0,i);h=y.toLowerCase();i=0;if(h.substring(0,7)=='http://')i+=7;else if(h.substring(0,8)=='https://')i+=8;h=h.substring(i);i=h.indexOf(\"/\");if(i>0){h=h.substring(0,i);if(h.indexOf('g"
+"oogle')>=0){a=s.sp(a,'&');if(a.length>1){l=',q,ie,start,search_key,word,kw,cd,';for(j=0;j<a.length;j++){t=a[j];i=t.indexOf('=');if(i>0&&l.indexOf(','+t.substring(0,i)+',')>=0)b+=(b?'&':'')+t;else c"
+"+=(c?'&':'')+t}if(b&&c){y+='?'+b+'&'+c;if(''+x!=y)x=y}}}}}}return x};s.hav=function(){var s=this,qs='',fv=s.linkTrackVars,fe=s.linkTrackEvents,mn,i;if(s.pe){mn=s.pe.substring(0,1).toUpperCase()+s.p"
+"e.substring(1);if(s[mn]){fv=s[mn].trackVars;fe=s[mn].trackEvents}}fv=fv?fv+','+s.vl_l+','+s.vl_l2:'';for(i=0;i<s.va_t.length;i++){var k=s.va_t[i],v=s[k],b=k.substring(0,4),x=k.substring(4),n=parseI"
+"nt(x),q=k;if(v&&k!='linkName'&&k!='linkType'){if(s.pe||s.lnk||s.eo){if(fv&&(','+fv+',').indexOf(','+k+',')<0)v='';if(k=='events'&&fe)v=s.fs(v,fe)}if(v){if(k=='dynamicVariablePrefix')q='D';else if(k"
+"=='visitorID')q='vid';else if(k=='pageURL'){q='g';v=s.fl(v,255)}else if(k=='referrer'){q='r';v=s.fl(s.rf(v),255)}else if(k=='vmk'||k=='visitorMigrationKey')q='vmt';else if(k=='visitorMigrationServe"
+"r'){q='vmf';if(s.ssl&&s.visitorMigrationServerSecure)v=''}else if(k=='visitorMigrationServerSecure'){q='vmf';if(!s.ssl&&s.visitorMigrationServer)v=''}else if(k=='charSet'){q='ce';if(v.toUpperCase()"
+"=='AUTO')v='ISO8859-1';else if(s.em==2||s.em==3)v='UTF-8'}else if(k=='visitorNamespace')q='ns';else if(k=='cookieDomainPeriods')q='cdp';else if(k=='cookieLifetime')q='cl';else if(k=='variableProvid"
+"er')q='vvp';else if(k=='currencyCode')q='cc';else if(k=='channel')q='ch';else if(k=='transactionID')q='xact';else if(k=='campaign')q='v0';else if(k=='resolution')q='s';else if(k=='colorDepth')q='c'"
+";else if(k=='javascriptVersion')q='j';else if(k=='javaEnabled')q='v';else if(k=='cookiesEnabled')q='k';else if(k=='browserWidth')q='bw';else if(k=='browserHeight')q='bh';else if(k=='connectionType'"
+")q='ct';else if(k=='homepage')q='hp';else if(k=='plugins')q='p';else if(s.num(x)){if(b=='prop')q='c'+n;else if(b=='eVar')q='v'+n;else if(b=='list')q='l'+n;else if(b=='hier'){q='h'+n;v=s.fl(v,255)}}"
+"if(v)qs+='&'+q+'='+(k.substring(0,3)!='pev'?s.ape(v):v)}}}return qs};s.ltdf=function(t,h){t=t?t.toLowerCase():'';h=h?h.toLowerCase():'';var qi=h.indexOf('?');h=qi>=0?h.substring(0,qi):h;if(t&&h.sub"
+"string(h.length-(t.length+1))=='.'+t)return 1;return 0};s.ltef=function(t,h){t=t?t.toLowerCase():'';h=h?h.toLowerCase():'';if(t&&h.indexOf(t)>=0)return 1;return 0};s.lt=function(h){var s=this,lft=s"
+".linkDownloadFileTypes,lef=s.linkExternalFilters,lif=s.linkInternalFilters;lif=lif?lif:s.wd.location.hostname;h=h.toLowerCase();if(s.trackDownloadLinks&&lft&&s.pt(lft,',','ltdf',h))return 'd';if(s."
+"trackExternalLinks&&h.substring(0,1)!='#'&&(lef||lif)&&(!lef||s.pt(lef,',','ltef',h))&&(!lif||!s.pt(lif,',','ltef',h)))return 'e';return ''};s.lc=new Function('e','var s=s_c_il['+s._in+'],b=s.eh(th"
+"is,\"onclick\");s.lnk=s.co(this);s.t();s.lnk=0;if(b)return this[b](e);return true');s.bc=new Function('e','var s=s_c_il['+s._in+'],f,tcf;if(s.d&&s.d.all&&s.d.all.cppXYctnr)return;s.eo=e.srcElement?"
+"e.srcElement:e.target;tcf=new Function(\"s\",\"var e;try{if(s.eo&&(s.eo.tagName||s.eo.parentElement||s.eo.parentNode))s.t()}catch(e){}\");tcf(s);s.eo=0');s.oh=function(o){var s=this,l=s.wd.location"
+",h=o.href?o.href:'',i,j,k,p;i=h.indexOf(':');j=h.indexOf('?');k=h.indexOf('/');if(h&&(i<0||(j>=0&&i>j)||(k>=0&&i>k))){p=o.protocol&&o.protocol.length>1?o.protocol:(l.protocol?l.protocol:'');i=l.pat"
+"hname.lastIndexOf('/');h=(p?p+'//':'')+(o.host?o.host:(l.host?l.host:''))+(h.substring(0,1)!='/'?l.pathname.substring(0,i<0?0:i)+'/':'')+h}return h};s.ot=function(o){var t=o.tagName;t=t&&t.toUpperC"
+"ase?t.toUpperCase():'';if(t=='SHAPE')t='';if(t){if((t=='INPUT'||t=='BUTTON')&&o.type&&o.type.toUpperCase)t=o.type.toUpperCase();else if(!t&&o.href)t='A';}return t};s.oid=function(o){var s=this,t=s."
+"ot(o),p,c,n='',x=0;if(t&&!o.s_oid){p=o.protocol;c=o.onclick;if(o.href&&(t=='A'||t=='AREA')&&(!c||!p||p.toLowerCase().indexOf('javascript')<0))n=s.oh(o);else if(c){n=s.rep(s.rep(s.rep(s.rep(''+c,\""
+"\\r\",''),\"\\n\",''),\"\\t\",''),' ','');x=2}else if(t=='INPUT'||t=='SUBMIT'){if(o.value)n=o.value;else if(o.innerText)n=o.innerText;else if(o.textContent)n=o.textContent;x=3}else if(o.src&&t=='IM"
+"AGE')n=o.src;if(n){o.s_oid=s.fl(n,100);o.s_oidt=x}}return o.s_oid};s.rqf=function(t,un){var s=this,e=t.indexOf('='),u=e>=0?t.substring(0,e):'',q=e>=0?s.epa(t.substring(e+1)):'';if(u&&q&&(','+u+',')"
+".indexOf(','+un+',')>=0){if(u!=s.un&&s.un.indexOf(',')>=0)q='&u='+u+q+'&u=0';return q}return ''};s.rq=function(un){if(!un)un=this.un;var s=this,c=un.indexOf(','),v=s.c_r('s_sq'),q='';if(c<0)return "
+"s.pt(v,'&','rqf',un);return s.pt(un,',','rq',0)};s.sqp=function(t,a){var s=this,e=t.indexOf('='),q=e<0?'':s.epa(t.substring(e+1));s.sqq[q]='';if(e>=0)s.pt(t.substring(0,e),',','sqs',q);return 0};s."
+"sqs=function(un,q){var s=this;s.squ[un]=q;return 0};s.sq=function(q){var s=this,k='s_sq',v=s.c_r(k),x,c=0;s.sqq=new Object;s.squ=new Object;s.sqq[q]='';s.pt(v,'&','sqp',0);s.pt(s.un,',','sqs',q);v="
+"'';for(x in s.squ)if(x&&(!Object||!Object.prototype||!Object.prototype[x]))s.sqq[s.squ[x]]+=(s.sqq[s.squ[x]]?',':'')+x;for(x in s.sqq)if(x&&(!Object||!Object.prototype||!Object.prototype[x])&&s.sqq"
+"[x]&&(x==q||c<2)){v+=(v?'&':'')+s.sqq[x]+'='+s.ape(x);c++}return s.c_w(k,v,0)};s.wdl=new Function('e','var s=s_c_il['+s._in+'],r=true,b=s.eh(s.wd,\"onload\"),i,o,oc;if(b)r=this[b](e);for(i=0;i<s.d."
+"links.length;i++){o=s.d.links[i];oc=o.onclick?\"\"+o.onclick:\"\";if((oc.indexOf(\"s_gs(\")<0||oc.indexOf(\".s_oc(\")>=0)&&oc.indexOf(\".tl(\")<0)s.eh(o,\"onclick\",0,s.lc);}return r');s.wds=functi"
+"on(){var s=this;if(s.apv>3&&(!s.isie||!s.ismac||s.apv>=5)){if(s.b&&s.b.attachEvent)s.b.attachEvent('onclick',s.bc);else if(s.b&&s.b.addEventListener)s.b.addEventListener('click',s.bc,false);else s."
+"eh(s.wd,'onload',0,s.wdl)}};s.vs=function(x){var s=this,v=s.visitorSampling,g=s.visitorSamplingGroup,k='s_vsn_'+s.un+(g?'_'+g:''),n=s.c_r(k),e=new Date,y=e.getYear();e.setYear(y+10+(y<1900?1900:0))"
+";if(v){v*=100;if(!n){if(!s.c_w(k,x,e))return 0;n=x}if(n%10000>v)return 0}return 1};s.dyasmf=function(t,m){if(t&&m&&m.indexOf(t)>=0)return 1;return 0};s.dyasf=function(t,m){var s=this,i=t?t.indexOf("
+"'='):-1,n,x;if(i>=0&&m){var n=t.substring(0,i),x=t.substring(i+1);if(s.pt(x,',','dyasmf',m))return n}return 0};s.uns=function(){var s=this,x=s.dynamicAccountSelection,l=s.dynamicAccountList,m=s.dyn"
+"amicAccountMatch,n,i;s.un=s.un.toLowerCase();if(x&&l){if(!m)m=s.wd.location.host;if(!m.toLowerCase)m=''+m;l=l.toLowerCase();m=m.toLowerCase();n=s.pt(l,';','dyasf',m);if(n)s.un=n}i=s.un.indexOf(',')"
+";s.fun=i<0?s.un:s.un.substring(0,i)};s.sa=function(un){var s=this;s.un=un;if(!s.oun)s.oun=un;else if((','+s.oun+',').indexOf(','+un+',')<0)s.oun+=','+un;s.uns()};s.m_i=function(n,a){var s=this,m,f="
+"n.substring(0,1),r,l,i;if(!s.m_l)s.m_l=new Object;if(!s.m_nl)s.m_nl=new Array;m=s.m_l[n];if(!a&&m&&m._e&&!m._i)s.m_a(n);if(!m){m=new Object,m._c='s_m';m._in=s.wd.s_c_in;m._il=s._il;m._il[m._in]=m;s"
+".wd.s_c_in++;m.s=s;m._n=n;m._l=new Array('_c','_in','_il','_i','_e','_d','_dl','s','n','_r','_g','_g1','_t','_t1','_x','_x1','_rs','_rr','_l');s.m_l[n]=m;s.m_nl[s.m_nl.length]=n}else if(m._r&&!m._m"
+"){r=m._r;r._m=m;l=m._l;for(i=0;i<l.length;i++)if(m[l[i]])r[l[i]]=m[l[i]];r._il[r._in]=r;m=s.m_l[n]=r}if(f==f.toUpperCase())s[n]=m;return m};s.m_a=new Function('n','g','e','if(!g)g=\"m_\"+n;var s=s_"
+"c_il['+s._in+'],c=s[g+\"_c\"],m,x,f=0;if(!c)c=s.wd[\"s_\"+g+\"_c\"];if(c&&s_d)s[g]=new Function(\"s\",s_ft(s_d(c)));x=s[g];if(!x)x=s.wd[\\'s_\\'+g];if(!x)x=s.wd[g];m=s.m_i(n,1);if(x&&(!m._i||g!=\"m"
+"_\"+n)){m._i=f=1;if((\"\"+x).indexOf(\"function\")>=0)x(s);else s.m_m(\"x\",n,x,e)}m=s.m_i(n,1);if(m._dl)m._dl=m._d=0;s.dlt();return f');s.m_m=function(t,n,d,e){t='_'+t;var s=this,i,x,m,f='_'+t,r=0"
+",u;if(s.m_l&&s.m_nl)for(i=0;i<s.m_nl.length;i++){x=s.m_nl[i];if(!n||x==n){m=s.m_i(x);u=m[t];if(u){if((''+u).indexOf('function')>=0){if(d&&e)u=m[t](d,e);else if(d)u=m[t](d);else u=m[t]()}}if(u)r=1;u"
+"=m[t+1];if(u&&!m[f]){if((''+u).indexOf('function')>=0){if(d&&e)u=m[t+1](d,e);else if(d)u=m[t+1](d);else u=m[t+1]()}}m[f]=1;if(u)r=1}}return r};s.m_ll=function(){var s=this,g=s.m_dl,i,o;if(g)for(i=0"
+";i<g.length;i++){o=g[i];if(o)s.loadModule(o.n,o.u,o.d,o.l,o.e,1);g[i]=0}};s.loadModule=function(n,u,d,l,e,ln){var s=this,m=0,i,g,o=0,f1,f2,c=s.h?s.h:s.b,b,tcf;if(n){i=n.indexOf(':');if(i>=0){g=n.su"
+"bstring(i+1);n=n.substring(0,i)}else g=\"m_\"+n;m=s.m_i(n)}if((l||(n&&!s.m_a(n,g)))&&u&&s.d&&c&&s.d.createElement){if(d){m._d=1;m._dl=1}if(ln){if(s.ssl)u=s.rep(u,'http:','https:');i='s_s:'+s._in+':"
+"'+n+':'+g;b='var s=s_c_il['+s._in+'],o=s.d.getElementById(\"'+i+'\");if(s&&o){if(!o.l&&s.wd.'+g+'){o.l=1;if(o.i)clearTimeout(o.i);o.i=0;s.m_a(\"'+n+'\",\"'+g+'\"'+(e?',\"'+e+'\"':'')+')}';f2=b+'o.c"
+"++;if(!s.maxDelay)s.maxDelay=250;if(!o.l&&o.c<(s.maxDelay*2)/100)o.i=setTimeout(o.f2,100)}';f1=new Function('e',b+'}');tcf=new Function('s','c','i','u','f1','f2','var e,o=0;try{o=s.d.createElement("
+"\"script\");if(o){o.type=\"text/javascript\";'+(n?'o.id=i;o.defer=true;o.onload=o.onreadystatechange=f1;o.f2=f2;o.l=0;':'')+'o.src=u;c.appendChild(o);'+(n?'o.c=0;o.i=setTimeout(f2,100)':'')+'}}catc"
+"h(e){o=0}return o');o=tcf(s,c,i,u,f1,f2)}else{o=new Object;o.n=n+':'+g;o.u=u;o.d=d;o.l=l;o.e=e;g=s.m_dl;if(!g)g=s.m_dl=new Array;i=0;while(i<g.length&&g[i])i++;g[i]=o}}else if(n){m=s.m_i(n);m._e=1}"
+"return m};s.vo1=function(t,a){if(a[t]||a['!'+t])this[t]=a[t]};s.vo2=function(t,a){if(!a[t]){a[t]=this[t];if(!a[t])a['!'+t]=1}};s.dlt=new Function('var s=s_c_il['+s._in+'],d=new Date,i,vo,f=0;if(s.d"
+"ll)for(i=0;i<s.dll.length;i++){vo=s.dll[i];if(vo){if(!s.m_m(\"d\")||d.getTime()-vo._t>=s.maxDelay){s.dll[i]=0;s.t(vo)}else f=1}}if(s.dli)clearTimeout(s.dli);s.dli=0;if(f){if(!s.dli)s.dli=setTimeout"
+"(s.dlt,s.maxDelay)}else s.dll=0');s.dl=function(vo){var s=this,d=new Date;if(!vo)vo=new Object;s.pt(s.vl_g,',','vo2',vo);vo._t=d.getTime();if(!s.dll)s.dll=new Array;s.dll[s.dll.length]=vo;if(!s.max"
+"Delay)s.maxDelay=250;s.dlt()};s.t=function(vo,id){var s=this,trk=1,tm=new Date,sed=Math&&Math.random?Math.floor(Math.random()*10000000000000):tm.getTime(),sess='s'+Math.floor(tm.getTime()/10800000)"
+"%10+sed,y=tm.getYear(),vt=tm.getDate()+'/'+tm.getMonth()+'/'+(y<1900?y+1900:y)+' '+tm.getHours()+':'+tm.getMinutes()+':'+tm.getSeconds()+' '+tm.getDay()+' '+tm.getTimezoneOffset(),tcf,tfs=s.gtfs(),"
+"ta='',q='',qs='',code='',vb=new Object;s.gl(s.vl_g);s.uns();s.m_ll();if(!s.td){var tl=tfs.location,a,o,i,x='',c='',v='',p='',bw='',bh='',j='1.0',k=s.c_w('s_cc','true',0)?'Y':'N',hp='',ct='',pn=0,ps"
+";if(String&&String.prototype){j='1.1';if(j.match){j='1.2';if(tm.setUTCDate){j='1.3';if(s.isie&&s.ismac&&s.apv>=5)j='1.4';if(pn.toPrecision){j='1.5';a=new Array;if(a.forEach){j='1.6';i=0;o=new Objec"
+"t;tcf=new Function('o','var e,i=0;try{i=new Iterator(o)}catch(e){}return i');i=tcf(o);if(i&&i.next)j='1.7'}}}}}if(s.apv>=4)x=screen.width+'x'+screen.height;if(s.isns||s.isopera){if(s.apv>=3){v=s.n."
+"javaEnabled()?'Y':'N';if(s.apv>=4){c=screen.pixelDepth;bw=s.wd.innerWidth;bh=s.wd.innerHeight}}s.pl=s.n.plugins}else if(s.isie){if(s.apv>=4){v=s.n.javaEnabled()?'Y':'N';c=screen.colorDepth;if(s.apv"
+">=5){bw=s.d.documentElement.offsetWidth;bh=s.d.documentElement.offsetHeight;if(!s.ismac&&s.b){tcf=new Function('s','tl','var e,hp=0;try{s.b.addBehavior(\"#default#homePage\");hp=s.b.isHomePage(tl)?"
+"\"Y\":\"N\"}catch(e){}return hp');hp=tcf(s,tl);tcf=new Function('s','var e,ct=0;try{s.b.addBehavior(\"#default#clientCaps\");ct=s.b.connectionType}catch(e){}return ct');ct=tcf(s)}}}else r=''}if(s.p"
+"l)while(pn<s.pl.length&&pn<30){ps=s.fl(s.pl[pn].name,100)+';';if(p.indexOf(ps)<0)p+=ps;pn++}s.resolution=x;s.colorDepth=c;s.javascriptVersion=j;s.javaEnabled=v;s.cookiesEnabled=k;s.browserWidth=bw;"
+"s.browserHeight=bh;s.connectionType=ct;s.homepage=hp;s.plugins=p;s.td=1}if(vo){s.pt(s.vl_g,',','vo2',vb);s.pt(s.vl_g,',','vo1',vo)}if(s.usePlugins)s.doPlugins(s);var l=s.wd.location,r=tfs.document."
+"referrer;if(!s.pageURL)s.pageURL=l.href?l.href:l;if(!s.referrer&&!s._1_referrer){s.referrer=r;s._1_referrer=1}if((vo&&vo._t)||!s.m_m('d')){s.m_m('g');if(s.lnk||s.eo){var o=s.eo?s.eo:s.lnk;if(!o)ret"
+"urn '';var p=s.pageName,w=1,t=s.ot(o),n=s.oid(o),x=o.s_oidt,h,l,i,oc;if(s.eo&&o==s.eo){while(o&&!n&&t!='BODY'){o=o.parentElement?o.parentElement:o.parentNode;if(!o)return '';t=s.ot(o);n=s.oid(o);x="
+"o.s_oidt}oc=o.onclick?''+o.onclick:'';if((oc.indexOf(\"s_gs(\")>=0&&oc.indexOf(\".s_oc(\")<0)||oc.indexOf(\".tl(\")>=0)return ''}ta=n?o.target:1;h=s.oh(o);i=h.indexOf('?');h=s.linkLeaveQueryString|"
+"|i<0?h:h.substring(0,i);l=s.linkName;t=s.linkType?s.linkType.toLowerCase():s.lt(h);if(t&&(h||l))q+='&pe=lnk_'+(t=='d'||t=='e'?s.ape(t):'o')+(h?'&pev1='+s.ape(h):'')+(l?'&pev2='+s.ape(l):'');else tr"
+"k=0;if(s.trackInlineStats){if(!p){p=s.pageURL;w=0}t=s.ot(o);i=o.sourceIndex;if(s.gg('objectID')){n=s.gg('objectID');x=1;i=1}if(p&&n&&t)qs='&pid='+s.ape(s.fl(p,255))+(w?'&pidt='+w:'')+'&oid='+s.ape("
+"s.fl(n,100))+(x?'&oidt='+x:'')+'&ot='+s.ape(t)+(i?'&oi='+i:'')}}if(!trk&&!qs)return '';s.sampled=s.vs(sed);if(trk){if(s.sampled)code=s.mr(sess,(vt?'&t='+s.ape(vt):'')+s.hav()+q+(qs?qs:s.rq()),0,id,"
+"ta);qs='';s.m_m('t');if(s.p_r)s.p_r();s.referrer=''}s.sq(qs);}else{s.dl(vo);}if(vo)s.pt(s.vl_g,',','vo1',vb);s.lnk=s.eo=s.linkName=s.linkType=s.wd.s_objectID=s.ppu=s.pe=s.pev1=s.pev2=s.pev3='';if(s"
+".pg)s.wd.s_lnk=s.wd.s_eo=s.wd.s_linkName=s.wd.s_linkType='';if(!id&&!s.tc){s.tc=1;s.flushBufferedRequests()}return code};s.tl=function(o,t,n,vo){var s=this;s.lnk=s.co(o);s.linkType=t;s.linkName=n;s"
+".t(vo)};if(pg){s.wd.s_co=function(o){var s=s_gi(\"_\",1,1);return s.co(o)};s.wd.s_gs=function(un){var s=s_gi(un,1,1);return s.t()};s.wd.s_dc=function(un){var s=s_gi(un,1);return s.t()}}s.ssl=(s.wd."
+"location.protocol.toLowerCase().indexOf('https')>=0);s.d=document;s.b=s.d.body;if(s.d.getElementsByTagName){s.h=s.d.getElementsByTagName('HEAD');if(s.h)s.h=s.h[0]}s.n=navigator;s.u=s.n.userAgent;s."
+"ns6=s.u.indexOf('Netscape6/');var apn=s.n.appName,v=s.n.appVersion,ie=v.indexOf('MSIE '),o=s.u.indexOf('Opera '),i;if(v.indexOf('Opera')>=0||o>0)apn='Opera';s.isie=(apn=='Microsoft Internet Explore"
+"r');s.isns=(apn=='Netscape');s.isopera=(apn=='Opera');s.ismac=(s.u.indexOf('Mac')>=0);if(o>0)s.apv=parseFloat(s.u.substring(o+6));else if(ie>0){s.apv=parseInt(i=v.substring(ie+5));if(s.apv>3)s.apv="
+"parseFloat(i)}else if(s.ns6>0)s.apv=parseFloat(s.u.substring(s.ns6+10));else s.apv=parseFloat(v);s.em=0;if(s.em.toPrecision)s.em=3;else if(String.fromCharCode){i=escape(String.fromCharCode(256)).to"
+"UpperCase();s.em=(i=='%C4%80'?2:(i=='%U0100'?1:0))}s.sa(un);s.vl_l='dynamicVariablePrefix,visitorID,vmk,visitorMigrationKey,visitorMigrationServer,visitorMigrationServerSecure,ppu,charSet,visitorNa"
+"mespace,cookieDomainPeriods,cookieLifetime,pageName,pageURL,referrer,currencyCode';s.va_l=s.sp(s.vl_l,',');s.vl_t=s.vl_l+',variableProvider,channel,server,pageType,transactionID,purchaseID,campaign"
+",state,zip,events,products,linkName,linkType';for(var n=1;n<51;n++)s.vl_t+=',prop'+n+',eVar'+n+',hier'+n+',list'+n;s.vl_l2=',tnt,pe,pev1,pev2,pev3,resolution,colorDepth,javascriptVersion,javaEnable"
+"d,cookiesEnabled,browserWidth,browserHeight,connectionType,homepage,plugins';s.vl_t+=s.vl_l2;s.va_t=s.sp(s.vl_t,',');s.vl_g=s.vl_t+',trackingServer,trackingServerSecure,trackingServerBase,fpCookieD"
+"omainPeriods,disableBufferedRequests,mobile,visitorSampling,visitorSamplingGroup,dynamicAccountSelection,dynamicAccountList,dynamicAccountMatch,trackDownloadLinks,trackExternalLinks,trackInlineStat"
+"s,linkLeaveQueryString,linkDownloadFileTypes,linkExternalFilters,linkInternalFilters,linkTrackVars,linkTrackEvents,linkNames,lnk,eo,_1_referrer';s.va_g=s.sp(s.vl_g,',');s.pg=pg;s.gl(s.vl_g);if(!ss)"
+"s.wds()",
w=window,l=w.s_c_il,n=navigator,u=n.userAgent,v=n.appVersion,e=v.indexOf('MSIE '),m=u.indexOf('Netscape6/'),a,i,s;if(un){un=un.toLowerCase();if(l)for(i=0;i<l.length;i++){s=l[i];if(!s._c||s._c=='s_c'){if(s.oun==un)return s;else if(s.fs&&s.sa&&s.fs(s.oun,un)){s.sa(un);return s}}}}w.s_an='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
w.s_sp=new Function("x","d","var a=new Array,i=0,j;if(x){if(x.split)a=x.split(d);else if(!d)for(i=0;i<x.length;i++)a[a.length]=x.substring(i,i+1);else while(i>=0){j=x.indexOf(d,i);a[a.length]=x.subst"
+"ring(i,j<0?x.length:j);i=j;if(i>=0)i+=d.length}}return a");
w.s_jn=new Function("a","d","var x='',i,j=a.length;if(a&&j>0){x=a[0];if(j>1){if(a.join)x=a.join(d);else for(i=1;i<j;i++)x+=d+a[i]}}return x");
w.s_rep=new Function("x","o","n","return s_jn(s_sp(x,o),n)");
w.s_d=new Function("x","var t='`^@$#',l=s_an,l2=new Object,x2,d,b=0,k,i=x.lastIndexOf('~~'),j,v,w;if(i>0){d=x.substring(0,i);x=x.substring(i+2);l=s_sp(l,'');for(i=0;i<62;i++)l2[l[i]]=i;t=s_sp(t,'');d"
+"=s_sp(d,'~');i=0;while(i<5){v=0;if(x.indexOf(t[i])>=0) {x2=s_sp(x,t[i]);for(j=1;j<x2.length;j++){k=x2[j].substring(0,1);w=t[i]+k;if(k!=' '){v=1;w=d[b+l2[k]]}x2[j]=w+x2[j].substring(1)}}if(v)x=s_jn("
+"x2,'');else{w=t[i]+' ';if(x.indexOf(w)>=0)x=s_rep(x,w,t[i]);i++;b+=62}}}return x");
w.s_fe=new Function("c","return s_rep(s_rep(s_rep(c,'\\\\','\\\\\\\\'),'\"','\\\\\"'),\"\\n\",\"\\\\n\")");
w.s_fa=new Function("f","var s=f.indexOf('(')+1,e=f.indexOf(')'),a='',c;while(s>=0&&s<e){c=f.substring(s,s+1);if(c==',')a+='\",\"';else if((\"\\n\\r\\t \").indexOf(c)<0)a+=c;s++}return a?'\"'+a+'\"':"
+"a");
w.s_ft=new Function("c","c+='';var s,e,o,a,d,q,f,h,x;s=c.indexOf('=function(');while(s>=0){s++;d=1;q='';x=0;f=c.substring(s);a=s_fa(f);e=o=c.indexOf('{',s);e++;while(d>0){h=c.substring(e,e+1);if(q){i"
+"f(h==q&&!x)q='';if(h=='\\\\')x=x?0:1;else x=0}else{if(h=='\"'||h==\"'\")q=h;if(h=='{')d++;if(h=='}')d--}if(d>0)e++}c=c.substring(0,s)+'new Function('+(a?a+',':'')+'\"'+s_fe(c.substring(o+1,e))+'\")"
+"'+c.substring(e+1);s=c.indexOf('=function(')}return c;");
c=s_d(c);if(e>0){a=parseInt(i=v.substring(e+5));if(a>3)a=parseFloat(i)}else if(m>0)a=parseFloat(u.substring(m+10));else a=parseFloat(v);if(a>=5&&v.indexOf('Opera')<0&&u.indexOf('Opera')<0){w.s_c=new Function("un","pg","ss","var s=this;"+c);return new s_c(un,pg,ss)}else s=new Function("un","pg","ss","var s=new Object;"+s_ft(c)+";return s");return s(un,pg,ss)}


//for EMC and Brocade page

var micrositeURL=document.location.toString();
if(micrositeURL.indexOf("benextsolutions")!=-1)
{
  micrositeURL=micrositeURL.slice(11);
  s.pageName=micrositeURL;
}
else
{
s.pageName="";
}
s.server="";
s.channel="";
s.pageType="";
if(typeof(window['pageType'])!= "undefined")
{
   s.pageType="errorPage"
} 
else
{
   s.pageType=""
}

s.prop1="";
s.prop2="";
s.prop3="";
s.prop4="";
s.prop5=""
/* E-commerce Variables */
s.campaign=""
s.state=""
s.zip=""
s.events=""
s.products=""
s.purchaseID=""
s.eVar1=""
s.eVar2=""
s.eVar3=""
s.eVar4=""
s.eVar5=""
/* Hierarchy Variables */
s.hier1=""
/* populate s.prop1-4 */

var URL = unescape(location.href);	

var xstart = URL.indexOf(".emc.com")+9;
var xend = URL.length;
var awebcurl = URL.substring(xstart,xend);
var set_s_prop1="";
var set_s_prop2="";
var set_s_prop3="";
var set_s_prop4="";
var set_hier="";
var arrylen="";
var sprops_splitted=awebcurl.split("/");
sprops_splitted.length=sprops_splitted.length-1;

if (sprops_splitted.length==0)
{
set_hier="home";
set_s_prop1="home";
set_s_prop2="home";
set_s_prop3="home";
set_s_prop4="home";
}
else
{
if (sprops_splitted[0]) 
{

set_s_prop1=sprops_splitted[0];
set_hier=set_s_prop1;
set_s_prop2=set_s_prop1;
set_s_prop3=set_s_prop1;
set_s_prop4=set_s_prop1;
}


if (sprops_splitted[1]) 
{
set_s_prop2=set_s_prop1+":"+sprops_splitted[1];
set_hier=set_s_prop2;
set_s_prop3=set_s_prop2;
set_s_prop4=set_s_prop2;

}
if (sprops_splitted[2]) 
{
set_s_prop3=set_s_prop2+":"+sprops_splitted[2];
set_hier=set_s_prop3;
set_s_prop4=set_s_prop3;
}


if (sprops_splitted[3]) 
{
set_s_prop4=set_s_prop3+":"+sprops_splitted[3];
set_hier=set_s_prop4;
}

set_hier=set_hier.replace(/:/,",")
set_hier=set_hier.replace(/:/,",")

}
/* Now set the final omniture s_prop*/
s.prop1=set_s_prop1;
s.prop2=set_s_prop2;
s.prop3=set_s_prop3;
s.prop4=set_s_prop4;
s.hier1=set_hier;

/*END of s.prop1-4,s.hier1 population code*/

if(typeof(omniSearchResults) != "undefined") {
     var searchKey="";
     if(document.SearchForm) {
	searchKey=document.SearchForm.searchString.value;
     }
     else  if(document.AdvancedSearchForm) { 
	searchKey=document.AdvancedSearchForm.searchString.value;
     }
	
	if(omniSearchResults>0) {
		s.prop5=omniSearchResults;
		if(searchKey !=null && searchKey.length>0){
			s.prop6=searchKey.toLowerCase();
		}
	}
	else {
		s.prop5="0";
		if(searchKey !=null && searchKey.length>0){
			s.prop7=searchKey.toLowerCase();
		}
	}
}

function setPdfpath(pdfUrl) {/*do nothing*/}


function mainNavTracking1(pageURL) {
	var URL = unescape(location.href);	
	var xstart = URL.indexOf(".emc.com")+9;
	var xend = URL.length;
	//var awebcurl = URL.substring(xstart,xend);
	var awebcurl = 'http://www.emc.com';
	alert('awebcurl '+awebcurl);
	var s=s_gi(s_account); 
	s.linkTrackVars='prop25,prop21,eVar21';
	s.prop25=awebcurl+'<>'+pageURL;
      	alert('s.prop25 '+s.prop25);
	s.tl(this,'o',s.prop25);
	
}

function mainNavTracking(pageURL) {
	location.href='http://www.emc.com'+pageURL;
}
//tracking print button


function printTracking() {
	var URL = unescape(location.href);	
	var xstart = URL.indexOf(".emc.com")+9;
	var xend = URL.length;
	var awebcurl = URL.substring(xstart,xend);
	var s=s_gi(s_account); 
	s.linkTrackVars='prop26,prop21,eVar21';
	s.prop26=awebcurl;
	s.tl(this,'o',s.prop26);
	
}

//tracking email button


function emailTracking() {
	var URL = unescape(location.href);	
	var xstart = URL.indexOf(".emc.com")+9;
	var xend = URL.length;
	var awebcurl = URL.substring(xstart,xend);
	var s=s_gi(s_account); 
	s.linkTrackVars='prop27,prop21,eVar21';
	s.prop27=awebcurl;
	s.tl(this,'o',s.prop27);
	
}

//accordion panel tracking
Event.observe(window,'load',function(){
     $$('.bar').each(function(el) {



         el.observe('click',function(ev) {
             
HomepageClickTracking(ev.element().innerHTML);
         });
     });
});

function HomepageClickTracking(click) {
	var s=s_gi(s_account); 
	s.linkTrackVars='prop28,prop21,eVar21,prop45';
	s.prop28=click;
	s.tl(this,'o');
	
}



// Link Tracking
 
/* Event.observe(window,'load',function(){
    $$('a').each(function(el) {
        el.observe('click',function(ev) {
		
		var s=s_gi(s_account);
		s.linkTrackVars='prop34,prop24,eVar38';
		
		var theText=ev.element().innerHTML.stripTags().stripScripts().strip();
		s.prop34=s.eVar38=theText;	
			
        if (ev.element().href.indexOf(".pdf")!=-1)
            {
           
        var theLink=ev.element().href;
        var xstart = theLink.indexOf(".emc.com")+9;
	    var xend = theLink.length;
	    var awebcurl = theLink.substring(xstart,xend);
        s.prop24=theText+" | "+s.pageName+" | "+theLink;
		
		var toPass="All links clicked on site outside of flash";
		
        s.tl(this,'o',toPass);
		
		

            }
        });
    });
});  */


// end download tracking



//PD tab tracking
Event.observe(window,'load',function(){
     $$('.productDetailHalfMidTabs a').each(function(el) {
         el.observe('click',function(ev) {
             
recordTabValue(ev.element().innerHTML.stripTags().stripScripts().strip());
         });
     });
});

function recordTabValue(theValue)
{
        var s=s_gi(s_account); 
                        s.linkTrackVars='prop47,prop21,eVar21,prop45';
                        s.prop47=theValue;
                        s.prop45=s.pageName;
                        s.tl(this,'o');
						
}





var vanityHref="";
var vanityHref = ReadCookie("vanity");

if(typeof(vanityHref) != "undefined") 
{
		
		if(vanityHref !=null && vanityHref.length>0 && awebcurl.length<15){
			s.referrer=unescape(location.href);
			s.pageURL=vanityHref;
			s.prop16=awebcurl+"---"+vanityHref;
		}

deleteCookie("vanity");
}

 var redirectHref="";
var redirectHref = ReadCookie("reDir");


if(typeof(redirectHref) != "undefined") 
{
		if(redirectHref !=null && redirectHref.length>0){
			s.referrer=unescape(location.href);
			s.pageURL=redirectHref;
			s.prop44=awebcurl+"---"+redirectHref;
		}

deleteCookie("reDir");

}


function missingFieldEvent()
{
                   var s=s_gi(s_account);
                   s.linkTrackVars="events,prop21,eVar21";
                   s.linkTrackEvents="event26";
                   s.events="event26"; 
                   s.tl(this,'o', s.events);
                   
}

//custom insight 48

if(typeof(ip)!=="undefined")
{
 s.prop48=ip;
}


//capture session id

var cookieString=document.cookie;
var sessionArray=cookieString.split(";");
 
var i=0;
for (i=0; i<sessionArray.length; i++)
{
 var sessionID=sessionArray[i];
 if(sessionID.indexOf("JS")!=-1)
 {
   var sessionStart=sessionID.indexOf("JSESSIONID=")+11;
   var sessionEnd=sessionID.length;
   sessionID=sessionID.substring(sessionStart,sessionEnd);
   s.eVar21=s.prop21=sessionID;
   
 }
   
}



/* function to reset all omniture variables if needed */
function resetOmnitureVars(){
s.prop1=""
s.prop2=""
s.prop3=""
s.prop4=""
s.prop5=""
s.prop6=""
s.prop7=""
s.prop8=""
s.prop9=""
s.prop10=""
s.prop11=""
s.prop12=""
s.prop13=""
s.prop14=""
s.prop15=""
s.prop16=""
s.prop17=""
s.prop18=""
s.prop19=""
s.prop22=""
s.prop23=""
s.prop24=""
s.prop25=""
s.prop26=""
s.prop27=""
s.prop28=""
s.prop29=""
s.prop30=""
s.prop31=""
s.prop32=""
s.prop33=""
s.prop34=""
s.prop35=""
s.prop36=""
s.prop37=""
s.prop38=""
s.prop39=""
s.prop40=""
s.prop41=""
s.prop42=""
s.prop43=""
s.prop44=""
s.prop45=""
s.prop46=""
s.prop47=""
s.prop48=""
s.prop49=""
s.prop50=""
s.eVar1=""
s.eVar2=""
s.eVar3=""
s.eVar4=""
s.eVar5=""
s.eVar6=""
s.eVar7=""
s.eVar8=""
s.eVar9=""
s.eVar10=""
s.eVar11=""
s.eVar12=""
s.eVar13=""
s.eVar14=""
s.eVar15=""
s.eVar16=""
s.eVar17=""
s.eVar18=""
s.eVar19=""
s.eVar22=""
s.eVar23=""
s.eVar24=""
s.eVar25=""
s.eVar26=""
s.eVar27=""
s.eVar28=""
s.eVar29=""
s.eVar30=""
s.eVar31=""
s.eVar32=""
s.eVar33=""
s.eVar34=""
s.eVar36=""
s.eVar37=""
s.eVar38=""
s.eVar39=""
s.eVar40=""
s.eVar41=""
s.eVar42=""
s.eVar43=""
s.eVar44=""
s.eVar45=""
s.eVar46=""
s.eVar47=""
s.eVar49=""
s.eVar50=""
s.events=""
s.products=""
s.purchaseID=""
s.state=""
s.zip=""
}


