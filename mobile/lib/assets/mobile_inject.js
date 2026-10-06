// Mobile viewport + polish hook for Jules WebView (parity preserved)
(function(){
  var m = document.querySelector('meta[name=viewport]');
  if(!m){ m=document.createElement('meta'); m.name='viewport'; document.head.appendChild(m); }
  m.content='width=device-width, initial-scale=1, maximum-scale=1';
})();
