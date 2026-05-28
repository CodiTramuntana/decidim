// changes the value "menu" of role attribute set by a11y on div dropdown-menu-account and
// dropdown-menu-account-mobile which are inappropriate for accessibility
document.addEventListener("DOMContentLoaded", () => {
  const dropdownDiv = document.querySelector("#dropdown-menu-account");
  const dropdownMobileDiv = document.querySelector("#dropdown-menu-account-mobile");
  if (dropdownDiv) {
    setTimeout(() => {
      dropdownDiv.setAttribute("role", "dialog")
      dropdownMobileDiv.setAttribute("role", "dialog")
    }, 300)
  }

  // changes the value "menu" of role attribute set by a11y on div dropdown-menu-filters which is inappropriate because the filter panel contains complex form elements, not menuitem children as required by the menu role
  const dropdownFiltersDiv = document.querySelector("#dropdown-menu-filters");
  if (dropdownFiltersDiv) {
    setTimeout(() => {
      dropdownFiltersDiv.setAttribute("role", "group")
    }, 300)
  }
  const triggerButtonMobile = document.querySelector("#dropdown-trigger-links-mobile");
  if (triggerButtonMobile) {
    triggerButtonMobile.addEventListener("click", () => {
      dropdownMobileDiv.setAttribute("aria-modal", "true")
    })
  }
});
