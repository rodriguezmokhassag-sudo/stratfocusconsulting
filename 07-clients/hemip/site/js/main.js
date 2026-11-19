/* HEMIP — scripts du site (aucune dépendance).
   RÉGLAGE : numéro WhatsApp qui reçoit les formulaires (format international, sans + ni espaces). */
var WHATSAPP = "242055865094";

(function () {
  "use strict";

  // Menu mobile
  var burger = document.querySelector(".burger");
  var nav = document.getElementById("nav");
  if (burger && nav) {
    burger.addEventListener("click", function () {
      var ouvert = burger.getAttribute("aria-expanded") === "true";
      burger.setAttribute("aria-expanded", String(!ouvert));
      nav.classList.toggle("ouvert", !ouvert);
    });
    nav.addEventListener("click", function (e) {
      if (e.target.tagName === "A") {
        burger.setAttribute("aria-expanded", "false");
        nav.classList.remove("ouvert");
      }
    });
  }

  // Apparition au défilement
  var blocs = document.querySelectorAll(".apparait");
  if ("IntersectionObserver" in window) {
    var obs = new IntersectionObserver(function (entrees) {
      entrees.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add("vu"); obs.unobserve(en.target); }
      });
    }, { threshold: 0.12 });
    blocs.forEach(function (b) { obs.observe(b); });
  } else {
    blocs.forEach(function (b) { b.classList.add("vu"); });
  }

  // Filtres des filières
  var boutons = document.querySelectorAll(".filtres button");
  boutons.forEach(function (btn) {
    btn.addEventListener("click", function () {
      var f = btn.getAttribute("data-filtre");
      boutons.forEach(function (b) { b.setAttribute("aria-pressed", String(b === btn)); });
      document.querySelectorAll("[data-parcours]").forEach(function (el) {
        el.hidden = !(f === "tous" || el.getAttribute("data-parcours") === f);
      });
    });
  });

  // Pré-sélection de la filière depuis l'adresse (?filiere=GL)
  var params = new URLSearchParams(window.location.search);
  var fil = params.get("filiere");
  var select = document.getElementById("f-filiere");
  if (fil && select) {
    for (var i = 0; i < select.options.length; i++) {
      if (select.options[i].value === fil) { select.selectedIndex = i; break; }
    }
  }
  var objet = params.get("objet");
  var selObjet = document.getElementById("c-objet");
  if (objet && selObjet) {
    for (var j = 0; j < selObjet.options.length; j++) {
      if (selObjet.options[j].value === objet) { selObjet.selectedIndex = j; break; }
    }
  }

  // Formulaires -> message WhatsApp pré-rempli
  document.querySelectorAll("form[data-whatsapp]").forEach(function (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var err = form.querySelector(".erreur");
      if (!form.checkValidity()) {
        if (err) err.classList.add("visible");
        form.reportValidity();
        return;
      }
      if (err) err.classList.remove("visible");
      var ordre = [], valeurs = {};
      form.querySelectorAll("input, select, textarea").forEach(function (ch) {
        if (!ch.name || ch.type === "submit") return;
        if ((ch.type === "radio" || ch.type === "checkbox") && !ch.checked) return;
        if (ch.tagName === "SELECT" && ch.value === "") return;
        var val = ch.tagName === "SELECT" ? ch.options[ch.selectedIndex].text : ch.value;
        val = (val || "").trim();
        if (!val) return;
        var lib = ch.getAttribute("data-libelle") || ch.name;
        if (valeurs[lib]) { valeurs[lib] += ", " + val; return; }
        valeurs[lib] = val;
        ordre.push(lib);
      });
      var texte = ["*" + form.getAttribute("data-whatsapp") + "*", ""]
        .concat(ordre.map(function (lib) { return lib + " : " + valeurs[lib]; }))
        .join("\n");
      window.open("https://wa.me/" + WHATSAPP + "?text=" + encodeURIComponent(texte), "_blank", "noopener");
    });
  });

  // Année du pied de page
  var an = document.getElementById("annee");
  if (an) an.textContent = new Date().getFullYear();
})();
