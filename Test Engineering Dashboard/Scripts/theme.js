(function(){
  if(window.__TED_THEME_INIT){ return; }
  window.__TED_THEME_INIT = true;
  // Apply saved theme early (avoid flash)
  var root = document.documentElement;
  var bodyEl = document.body || document.getElementsByTagName('body')[0];
  function getMode(){
    var dt = root.getAttribute('data-theme');
    return dt === 'light' ? 'light' : 'dark';
  }
  function applyTheme(mode){
    var isLight = mode === 'light';
    // remove both, then add one to avoid residual conflicts
    root.classList.remove('theme-light','theme-dark');
    if(bodyEl) bodyEl.classList.remove('theme-light','theme-dark');
    // set attribute for stronger CSS targets when needed
    try { root.setAttribute('data-theme', isLight ? 'light' : 'dark'); } catch(e){}
    // add desired classes
    root.classList.add(isLight ? 'theme-light' : 'theme-dark');
    if(bodyEl) bodyEl.classList.add(isLight ? 'theme-light' : 'theme-dark');
  }
  var saved = localStorage.getItem('tedTheme');
  applyTheme(saved === 'light' ? 'light' : 'dark');

  function toggleTheme(){
    // Add animation flag
    root.classList.add('theme-switching');
    var nextIsLight = !root.classList.contains('theme-light');
    applyTheme(nextIsLight ? 'light' : 'dark');
    localStorage.setItem('tedTheme', nextIsLight ? 'light':'dark');
    setTimeout(function(){ root.classList.remove('theme-switching'); }, 600);
  }

  // Public API
  window.TEDTheme = { toggle: toggleTheme };

  // Single delegated listener ensures reliability and avoids duplicate bindings
  document.addEventListener('click', function(e){
    try{
      var t = e.target && (e.target.closest ? e.target.closest('[data-theme-toggle]') : null);
      if(t){
        e.preventDefault();
        toggleTheme();
      }
    }catch(_){/* no-op */}
  });

  // On DOM ready, ensure body has the correct class for the current mode
  document.addEventListener('DOMContentLoaded', function(){
    if(!bodyEl){ bodyEl = document.body || document.getElementsByTagName('body')[0]; }
    try { applyTheme(getMode()); } catch(e){}
  });
})();
