// node_modules/govuk-frontend/dist/govuk/common/index.mjs
function getFragmentFromUrl(url) {
  if (!url.includes("#")) {
    return void 0;
  }
  return url.split("#").pop();
}
function getBreakpoint(name) {
  const property = `--govuk-breakpoint-${name}`;
  const value = window.getComputedStyle(document.documentElement).getPropertyValue(property);
  return {
    property,
    value: value || void 0
  };
}
function setFocus($element, options = {}) {
  var _options$onBeforeFocu;
  const isFocusable = $element.getAttribute("tabindex");
  if (!isFocusable) {
    $element.setAttribute("tabindex", "-1");
  }
  function onFocus() {
    $element.addEventListener("blur", onBlur, {
      once: true
    });
  }
  function onBlur() {
    var _options$onBlur;
    (_options$onBlur = options.onBlur) == null || _options$onBlur.call($element);
    if (!isFocusable) {
      $element.removeAttribute("tabindex");
    }
  }
  $element.addEventListener("focus", onFocus, {
    once: true
  });
  (_options$onBeforeFocu = options.onBeforeFocus) == null || _options$onBeforeFocu.call($element);
  $element.focus();
}
function isInitialised($root, moduleName) {
  return $root instanceof HTMLElement && $root.hasAttribute(`data-${moduleName}-init`);
}
function isSupported($scope = document.body) {
  if (!$scope) {
    return false;
  }
  return $scope.classList.contains("govuk-frontend-supported");
}
function isArray(option) {
  return Array.isArray(option);
}
function isObject(option) {
  return !!option && typeof option === "object" && !isArray(option);
}
function formatErrorMessage(Component2, message) {
  return `${Component2.moduleName}: ${message}`;
}

// node_modules/govuk-frontend/dist/govuk/errors/index.mjs
var GOVUKFrontendError = class extends Error {
  constructor(...args) {
    super(...args);
    this.name = "GOVUKFrontendError";
  }
};
var SupportError = class extends GOVUKFrontendError {
  /**
   * Checks if GOV.UK Frontend is supported on this page
   *
   * @param {HTMLElement | null} [$scope] - HTML element `<body>` checked for browser support
   */
  constructor($scope = document.body) {
    const supportMessage = "noModule" in HTMLScriptElement.prototype ? 'GOV.UK Frontend initialised without `<body class="govuk-frontend-supported">` from template `<script>` snippet' : "GOV.UK Frontend is not supported in this browser";
    super($scope ? supportMessage : 'GOV.UK Frontend initialised without `<script type="module">`');
    this.name = "SupportError";
  }
};
var ConfigError = class extends GOVUKFrontendError {
  constructor(...args) {
    super(...args);
    this.name = "ConfigError";
  }
};
var ElementError = class extends GOVUKFrontendError {
  constructor(messageOrOptions) {
    let message = typeof messageOrOptions === "string" ? messageOrOptions : "";
    if (typeof messageOrOptions === "object") {
      const {
        component,
        identifier,
        element,
        expectedType
      } = messageOrOptions;
      message = identifier;
      message += element ? ` is not of type ${expectedType != null ? expectedType : "HTMLElement"}` : " not found";
      message = formatErrorMessage(component, message);
    }
    super(message);
    this.name = "ElementError";
  }
};
var InitError = class extends GOVUKFrontendError {
  constructor(componentOrMessage) {
    const message = typeof componentOrMessage === "string" ? componentOrMessage : formatErrorMessage(componentOrMessage, `Root element (\`$root\`) already initialised`);
    super(message);
    this.name = "InitError";
  }
};

// node_modules/govuk-frontend/dist/govuk/component.mjs
var Component = class {
  /**
   * Returns the root element of the component
   *
   * @protected
   * @returns {RootElementType} - the root element of component
   */
  get $root() {
    return this._$root;
  }
  constructor($root) {
    this._$root = void 0;
    const childConstructor = this.constructor;
    if (typeof childConstructor.moduleName !== "string") {
      throw new InitError(`\`moduleName\` not defined in component`);
    }
    if (!($root instanceof childConstructor.elementType)) {
      throw new ElementError({
        element: $root,
        component: childConstructor,
        identifier: "Root element (`$root`)",
        expectedType: childConstructor.elementType.name
      });
    } else {
      this._$root = $root;
    }
    childConstructor.checkSupport();
    this.checkInitialised();
    const moduleName = childConstructor.moduleName;
    this.$root.setAttribute(`data-${moduleName}-init`, "");
  }
  checkInitialised() {
    const constructor = this.constructor;
    const moduleName = constructor.moduleName;
    if (moduleName && isInitialised(this.$root, moduleName)) {
      throw new InitError(constructor);
    }
  }
  static checkSupport() {
    if (!isSupported()) {
      throw new SupportError();
    }
  }
};
Component.elementType = HTMLElement;

// node_modules/govuk-frontend/dist/govuk/common/configuration.mjs
var configOverride = Symbol.for("configOverride");
var ConfigurableComponent = class extends Component {
  [configOverride](param) {
    return {};
  }
  /**
   * Returns the root element of the component
   *
   * @protected
   * @returns {ConfigurationType} - the root element of component
   */
  get config() {
    return this._config;
  }
  constructor($root, config) {
    super($root);
    this._config = void 0;
    const childConstructor = this.constructor;
    if (!isObject(childConstructor.defaults)) {
      throw new ConfigError(formatErrorMessage(childConstructor, "Config passed as parameter into constructor but no defaults defined"));
    }
    const datasetConfig = normaliseDataset(childConstructor, this._$root.dataset);
    this._config = mergeConfigs(childConstructor.defaults, config != null ? config : {}, this[configOverride](datasetConfig), datasetConfig);
  }
};
function normaliseString(value, property) {
  const trimmedValue = value ? value.trim() : "";
  let output;
  let outputType = property == null ? void 0 : property.type;
  if (!outputType) {
    if (["true", "false"].includes(trimmedValue)) {
      outputType = "boolean";
    }
    if (trimmedValue.length > 0 && isFinite(Number(trimmedValue))) {
      outputType = "number";
    }
  }
  switch (outputType) {
    case "boolean":
      output = trimmedValue === "true";
      break;
    case "number":
      output = Number(trimmedValue);
      break;
    default:
      output = value;
  }
  return output;
}
function normaliseDataset(Component2, dataset) {
  if (!isObject(Component2.schema)) {
    throw new ConfigError(formatErrorMessage(Component2, "Config passed as parameter into constructor but no schema defined"));
  }
  const out = {};
  const entries = Object.entries(Component2.schema.properties);
  for (const entry of entries) {
    const [namespace, property] = entry;
    const field = namespace.toString();
    if (field in dataset) {
      out[field] = normaliseString(dataset[field], property);
    }
    if ((property == null ? void 0 : property.type) === "object") {
      out[field] = extractConfigByNamespace(Component2.schema, dataset, namespace);
    }
  }
  return out;
}
function mergeConfigs(...configObjects) {
  const formattedConfigObject = {};
  for (const configObject of configObjects) {
    for (const key of Object.keys(configObject)) {
      const option = formattedConfigObject[key];
      const override = configObject[key];
      if (isObject(option) && isObject(override)) {
        formattedConfigObject[key] = mergeConfigs(option, override);
      } else {
        formattedConfigObject[key] = override;
      }
    }
  }
  return formattedConfigObject;
}
function validateConfig(schema, config) {
  const validationErrors = [];
  for (const [name, conditions] of Object.entries(schema)) {
    const errors = [];
    if (Array.isArray(conditions)) {
      for (const {
        required,
        errorMessage
      } of conditions) {
        if (!required.every((key) => !!config[key])) {
          errors.push(errorMessage);
        }
      }
      if (name === "anyOf" && !(conditions.length - errors.length >= 1)) {
        validationErrors.push(...errors);
      }
    }
  }
  return validationErrors;
}
function extractConfigByNamespace(schema, dataset, namespace) {
  const property = schema.properties[namespace];
  if ((property == null ? void 0 : property.type) !== "object") {
    return;
  }
  const newObject = {
    [namespace]: {}
  };
  for (const [key, value] of Object.entries(dataset)) {
    let current = newObject;
    const keyParts = key.split(".");
    for (const [index, name] of keyParts.entries()) {
      if (isObject(current)) {
        if (index < keyParts.length - 1) {
          if (!isObject(current[name])) {
            current[name] = {};
          }
          current = current[name];
        } else if (key !== namespace) {
          current[name] = normaliseString(value);
        }
      }
    }
  }
  return newObject[namespace];
}

// node_modules/govuk-frontend/dist/govuk/i18n.mjs
var I18n = class _I18n {
  constructor(translations = {}, config = {}) {
    var _config$locale;
    this.translations = void 0;
    this.locale = void 0;
    this.translations = translations;
    this.locale = (_config$locale = config.locale) != null ? _config$locale : document.documentElement.lang || "en";
  }
  t(lookupKey, options) {
    if (!lookupKey) {
      throw new Error("i18n: lookup key missing");
    }
    let translation = this.translations[lookupKey];
    if (typeof (options == null ? void 0 : options.count) === "number" && typeof translation === "object") {
      const translationPluralForm = translation[this.getPluralSuffix(lookupKey, options.count)];
      if (translationPluralForm) {
        translation = translationPluralForm;
      }
    }
    if (typeof translation === "string") {
      if (translation.match(/%{(.\S+)}/)) {
        if (!options) {
          throw new Error("i18n: cannot replace placeholders in string if no option data provided");
        }
        return this.replacePlaceholders(translation, options);
      }
      return translation;
    }
    return lookupKey;
  }
  replacePlaceholders(translationString, options) {
    const formatter = Intl.NumberFormat.supportedLocalesOf(this.locale).length ? new Intl.NumberFormat(this.locale) : void 0;
    return translationString.replace(/%{(.\S+)}/g, function(placeholderWithBraces, placeholderKey) {
      if (Object.prototype.hasOwnProperty.call(options, placeholderKey)) {
        const placeholderValue = options[placeholderKey];
        if (placeholderValue === false || typeof placeholderValue !== "number" && typeof placeholderValue !== "string") {
          return "";
        }
        if (typeof placeholderValue === "number") {
          return formatter ? formatter.format(placeholderValue) : `${placeholderValue}`;
        }
        return placeholderValue;
      }
      throw new Error(`i18n: no data found to replace ${placeholderWithBraces} placeholder in string`);
    });
  }
  hasIntlPluralRulesSupport() {
    return Boolean("PluralRules" in window.Intl && Intl.PluralRules.supportedLocalesOf(this.locale).length);
  }
  getPluralSuffix(lookupKey, count) {
    count = Number(count);
    if (!isFinite(count)) {
      return "other";
    }
    const translation = this.translations[lookupKey];
    const preferredForm = this.hasIntlPluralRulesSupport() ? new Intl.PluralRules(this.locale).select(count) : this.selectPluralFormUsingFallbackRules(count);
    if (typeof translation === "object") {
      if (preferredForm in translation) {
        return preferredForm;
      } else if ("other" in translation) {
        console.warn(`i18n: Missing plural form ".${preferredForm}" for "${this.locale}" locale. Falling back to ".other".`);
        return "other";
      }
    }
    throw new Error(`i18n: Plural form ".other" is required for "${this.locale}" locale`);
  }
  selectPluralFormUsingFallbackRules(count) {
    count = Math.abs(Math.floor(count));
    const ruleset = this.getPluralRulesForLocale();
    if (ruleset) {
      return _I18n.pluralRules[ruleset](count);
    }
    return "other";
  }
  getPluralRulesForLocale() {
    const localeShort = this.locale.split("-")[0];
    for (const pluralRule in _I18n.pluralRulesMap) {
      const languages = _I18n.pluralRulesMap[pluralRule];
      if (languages.includes(this.locale) || languages.includes(localeShort)) {
        return pluralRule;
      }
    }
  }
};
I18n.pluralRulesMap = {
  arabic: ["ar"],
  chinese: ["my", "zh", "id", "ja", "jv", "ko", "ms", "th", "vi"],
  french: ["hy", "bn", "fr", "gu", "hi", "fa", "pa", "zu"],
  german: ["af", "sq", "az", "eu", "bg", "ca", "da", "nl", "en", "et", "fi", "ka", "de", "el", "hu", "lb", "no", "so", "sw", "sv", "ta", "te", "tr", "ur"],
  irish: ["ga"],
  russian: ["ru", "uk"],
  scottish: ["gd"],
  spanish: ["pt-PT", "it", "es"],
  welsh: ["cy"]
};
I18n.pluralRules = {
  arabic(n) {
    if (n === 0) {
      return "zero";
    }
    if (n === 1) {
      return "one";
    }
    if (n === 2) {
      return "two";
    }
    if (n % 100 >= 3 && n % 100 <= 10) {
      return "few";
    }
    if (n % 100 >= 11 && n % 100 <= 99) {
      return "many";
    }
    return "other";
  },
  chinese() {
    return "other";
  },
  french(n) {
    return n === 0 || n === 1 ? "one" : "other";
  },
  german(n) {
    return n === 1 ? "one" : "other";
  },
  irish(n) {
    if (n === 1) {
      return "one";
    }
    if (n === 2) {
      return "two";
    }
    if (n >= 3 && n <= 6) {
      return "few";
    }
    if (n >= 7 && n <= 10) {
      return "many";
    }
    return "other";
  },
  russian(n) {
    const lastTwo = n % 100;
    const last = lastTwo % 10;
    if (last === 1 && lastTwo !== 11) {
      return "one";
    }
    if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) {
      return "few";
    }
    if (last === 0 || last >= 5 && last <= 9 || lastTwo >= 11 && lastTwo <= 14) {
      return "many";
    }
    return "other";
  },
  scottish(n) {
    if (n === 1 || n === 11) {
      return "one";
    }
    if (n === 2 || n === 12) {
      return "two";
    }
    if (n >= 3 && n <= 10 || n >= 13 && n <= 19) {
      return "few";
    }
    return "other";
  },
  spanish(n) {
    if (n === 1) {
      return "one";
    }
    if (n % 1e6 === 0 && n !== 0) {
      return "many";
    }
    return "other";
  },
  welsh(n) {
    if (n === 0) {
      return "zero";
    }
    if (n === 1) {
      return "one";
    }
    if (n === 2) {
      return "two";
    }
    if (n === 3) {
      return "few";
    }
    if (n === 6) {
      return "many";
    }
    return "other";
  }
};

// node_modules/govuk-frontend/dist/govuk/components/accordion/accordion.mjs
var Accordion = class _Accordion extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - HTML element to use for accordion
   * @param {AccordionConfig} [config] - Accordion config
   */
  constructor($root, config = {}) {
    super($root, config);
    this.i18n = void 0;
    this.controlsClass = "govuk-accordion__controls";
    this.showAllClass = "govuk-accordion__show-all";
    this.showAllTextClass = "govuk-accordion__show-all-text";
    this.sectionClass = "govuk-accordion__section";
    this.sectionExpandedClass = "govuk-accordion__section--expanded";
    this.sectionButtonClass = "govuk-accordion__section-button";
    this.sectionHeaderClass = "govuk-accordion__section-header";
    this.sectionHeadingClass = "govuk-accordion__section-heading";
    this.sectionHeadingDividerClass = "govuk-accordion__section-heading-divider";
    this.sectionHeadingTextClass = "govuk-accordion__section-heading-text";
    this.sectionHeadingTextFocusClass = "govuk-accordion__section-heading-text-focus";
    this.sectionShowHideToggleClass = "govuk-accordion__section-toggle";
    this.sectionShowHideToggleFocusClass = "govuk-accordion__section-toggle-focus";
    this.sectionShowHideTextClass = "govuk-accordion__section-toggle-text";
    this.upChevronIconClass = "govuk-accordion-nav__chevron";
    this.downChevronIconClass = "govuk-accordion-nav__chevron--down";
    this.sectionSummaryClass = "govuk-accordion__section-summary";
    this.sectionSummaryFocusClass = "govuk-accordion__section-summary-focus";
    this.sectionContentClass = "govuk-accordion__section-content";
    this.$sections = void 0;
    this.$showAllButton = null;
    this.$showAllIcon = null;
    this.$showAllText = null;
    this.i18n = new I18n(this.config.i18n);
    const $sections = this.$root.querySelectorAll(`.${this.sectionClass}`);
    if (!$sections.length) {
      throw new ElementError({
        component: _Accordion,
        identifier: `Sections (\`<div class="${this.sectionClass}">\`)`
      });
    }
    this.$sections = $sections;
    this.initControls();
    this.initSectionHeaders();
    this.updateShowAllButton(this.areAllSectionsOpen());
  }
  initControls() {
    this.$showAllButton = document.createElement("button");
    this.$showAllButton.setAttribute("type", "button");
    this.$showAllButton.setAttribute("class", this.showAllClass);
    this.$showAllButton.setAttribute("aria-expanded", "false");
    this.$showAllIcon = document.createElement("span");
    this.$showAllIcon.classList.add(this.upChevronIconClass);
    this.$showAllButton.appendChild(this.$showAllIcon);
    const $accordionControls = document.createElement("div");
    $accordionControls.setAttribute("class", this.controlsClass);
    $accordionControls.appendChild(this.$showAllButton);
    this.$root.insertBefore($accordionControls, this.$root.firstChild);
    this.$showAllText = document.createElement("span");
    this.$showAllText.classList.add(this.showAllTextClass);
    this.$showAllButton.appendChild(this.$showAllText);
    this.$showAllButton.addEventListener("click", () => this.onShowOrHideAllToggle());
    if ("onbeforematch" in document) {
      document.addEventListener("beforematch", (event) => this.onBeforeMatch(event));
    }
  }
  initSectionHeaders() {
    this.$sections.forEach(($section, i) => {
      const $header = $section.querySelector(`.${this.sectionHeaderClass}`);
      if (!$header) {
        throw new ElementError({
          component: _Accordion,
          identifier: `Section headers (\`<div class="${this.sectionHeaderClass}">\`)`
        });
      }
      this.constructHeaderMarkup($header, i);
      this.setExpanded(this.isExpanded($section), $section);
      $header.addEventListener("click", () => this.onSectionToggle($section));
      this.setInitialState($section);
    });
  }
  constructHeaderMarkup($header, index) {
    const $span = $header.querySelector(`.${this.sectionButtonClass}`);
    const $heading = $header.querySelector(`.${this.sectionHeadingClass}`);
    const $summary = $header.querySelector(`.${this.sectionSummaryClass}`);
    if (!$heading) {
      throw new ElementError({
        component: _Accordion,
        identifier: `Section heading (\`.${this.sectionHeadingClass}\`)`
      });
    }
    if (!$span) {
      throw new ElementError({
        component: _Accordion,
        identifier: `Section button placeholder (\`<span class="${this.sectionButtonClass}">\`)`
      });
    }
    const $button = document.createElement("button");
    $button.setAttribute("type", "button");
    $button.setAttribute("aria-controls", `${this.$root.id}-content-${index + 1}`);
    for (const attr of Array.from($span.attributes)) {
      if (attr.name !== "id") {
        $button.setAttribute(attr.name, attr.value);
      }
    }
    const $headingText = document.createElement("span");
    $headingText.classList.add(this.sectionHeadingTextClass);
    $headingText.id = $span.id;
    const $headingTextFocus = document.createElement("span");
    $headingTextFocus.classList.add(this.sectionHeadingTextFocusClass);
    $headingText.appendChild($headingTextFocus);
    Array.from($span.childNodes).forEach(($child) => $headingTextFocus.appendChild($child));
    const $showHideToggle = document.createElement("span");
    $showHideToggle.classList.add(this.sectionShowHideToggleClass);
    $showHideToggle.setAttribute("data-nosnippet", "");
    const $showHideToggleFocus = document.createElement("span");
    $showHideToggleFocus.classList.add(this.sectionShowHideToggleFocusClass);
    $showHideToggle.appendChild($showHideToggleFocus);
    const $showHideText = document.createElement("span");
    const $showHideIcon = document.createElement("span");
    $showHideIcon.classList.add(this.upChevronIconClass);
    $showHideToggleFocus.appendChild($showHideIcon);
    $showHideText.classList.add(this.sectionShowHideTextClass);
    $showHideToggleFocus.appendChild($showHideText);
    $button.appendChild($headingText);
    $button.appendChild(this.getButtonPunctuationEl());
    if ($summary) {
      const $summarySpan = document.createElement("span");
      const $summarySpanFocus = document.createElement("span");
      $summarySpanFocus.classList.add(this.sectionSummaryFocusClass);
      $summarySpan.appendChild($summarySpanFocus);
      for (const attr of Array.from($summary.attributes)) {
        $summarySpan.setAttribute(attr.name, attr.value);
      }
      Array.from($summary.childNodes).forEach(($child) => $summarySpanFocus.appendChild($child));
      $summary.remove();
      $button.appendChild($summarySpan);
      $button.appendChild(this.getButtonPunctuationEl());
    }
    $button.appendChild($showHideToggle);
    $heading.removeChild($span);
    $heading.appendChild($button);
  }
  onBeforeMatch(event) {
    const $fragment = event.target;
    if (!($fragment instanceof Element)) {
      return;
    }
    const $section = $fragment.closest(`.${this.sectionClass}`);
    if ($section) {
      this.setExpanded(true, $section);
    }
  }
  onSectionToggle($section) {
    const nowExpanded = !this.isExpanded($section);
    this.setExpanded(nowExpanded, $section);
    this.storeState($section, nowExpanded);
  }
  onShowOrHideAllToggle() {
    const nowExpanded = !this.areAllSectionsOpen();
    this.$sections.forEach(($section) => {
      this.setExpanded(nowExpanded, $section);
      this.storeState($section, nowExpanded);
    });
    this.updateShowAllButton(nowExpanded);
  }
  setExpanded(expanded, $section) {
    const $showHideIcon = $section.querySelector(`.${this.upChevronIconClass}`);
    const $showHideText = $section.querySelector(`.${this.sectionShowHideTextClass}`);
    const $button = $section.querySelector(`.${this.sectionButtonClass}`);
    const $content = $section.querySelector(`.${this.sectionContentClass}`);
    if (!$content) {
      throw new ElementError({
        component: _Accordion,
        identifier: `Section content (\`<div class="${this.sectionContentClass}">\`)`
      });
    }
    if (!$showHideIcon || !$showHideText || !$button) {
      return;
    }
    const newButtonText = expanded ? this.i18n.t("hideSection") : this.i18n.t("showSection");
    $showHideText.textContent = newButtonText;
    $button.setAttribute("aria-expanded", `${expanded}`);
    const ariaLabelParts = [];
    const $headingText = $section.querySelector(`.${this.sectionHeadingTextClass}`);
    if ($headingText) {
      ariaLabelParts.push(`${$headingText.textContent}`.trim());
    }
    const $summary = $section.querySelector(`.${this.sectionSummaryClass}`);
    if ($summary) {
      ariaLabelParts.push(`${$summary.textContent}`.trim());
    }
    const ariaLabelMessage = expanded ? this.i18n.t("hideSectionAriaLabel") : this.i18n.t("showSectionAriaLabel");
    ariaLabelParts.push(ariaLabelMessage);
    $button.setAttribute("aria-label", ariaLabelParts.join(" , "));
    if (expanded) {
      $content.removeAttribute("hidden");
      $section.classList.add(this.sectionExpandedClass);
      $showHideIcon.classList.remove(this.downChevronIconClass);
    } else {
      $content.setAttribute("hidden", "until-found");
      $section.classList.remove(this.sectionExpandedClass);
      $showHideIcon.classList.add(this.downChevronIconClass);
    }
    this.updateShowAllButton(this.areAllSectionsOpen());
  }
  isExpanded($section) {
    return $section.classList.contains(this.sectionExpandedClass);
  }
  areAllSectionsOpen() {
    return Array.from(this.$sections).every(($section) => this.isExpanded($section));
  }
  updateShowAllButton(expanded) {
    if (!this.$showAllButton || !this.$showAllText || !this.$showAllIcon) {
      return;
    }
    this.$showAllButton.setAttribute("aria-expanded", expanded.toString());
    this.$showAllText.textContent = expanded ? this.i18n.t("hideAllSections") : this.i18n.t("showAllSections");
    this.$showAllIcon.classList.toggle(this.downChevronIconClass, !expanded);
  }
  /**
   * Get the identifier for a section
   *
   * We need a unique way of identifying each content in the Accordion.
   * Since an `#id` should be unique and an `id` is required for `aria-`
   * attributes `id` can be safely used.
   *
   * @param {Element} $section - Section element
   * @returns {string | undefined | null} Identifier for section
   */
  getIdentifier($section) {
    const $button = $section.querySelector(`.${this.sectionButtonClass}`);
    return $button == null ? void 0 : $button.getAttribute("aria-controls");
  }
  storeState($section, isExpanded) {
    if (!this.config.rememberExpanded) {
      return;
    }
    const id = this.getIdentifier($section);
    if (id) {
      try {
        window.sessionStorage.setItem(id, isExpanded.toString());
      } catch (exception) {
      }
    }
  }
  setInitialState($section) {
    if (!this.config.rememberExpanded) {
      return;
    }
    const id = this.getIdentifier($section);
    if (id) {
      try {
        const state = window.sessionStorage.getItem(id);
        if (state !== null) {
          this.setExpanded(state === "true", $section);
        }
      } catch (exception) {
      }
    }
  }
  getButtonPunctuationEl() {
    const $punctuationEl = document.createElement("span");
    $punctuationEl.classList.add("govuk-visually-hidden", this.sectionHeadingDividerClass);
    $punctuationEl.textContent = ", ";
    return $punctuationEl;
  }
};
Accordion.moduleName = "govuk-accordion";
Accordion.defaults = Object.freeze({
  i18n: {
    hideAllSections: "Hide all sections",
    hideSection: "Hide",
    hideSectionAriaLabel: "Hide this section",
    showAllSections: "Show all sections",
    showSection: "Show",
    showSectionAriaLabel: "Show this section"
  },
  rememberExpanded: true
});
Accordion.schema = Object.freeze({
  properties: {
    i18n: {
      type: "object"
    },
    rememberExpanded: {
      type: "boolean"
    }
  }
});

// node_modules/govuk-frontend/dist/govuk/components/button/button.mjs
var DEBOUNCE_TIMEOUT_IN_SECONDS = 1;
var Button = class extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - HTML element to use for button
   * @param {ButtonConfig} [config] - Button config
   */
  constructor($root, config = {}) {
    super($root, config);
    this.debounceFormSubmitTimer = null;
    this.$root.addEventListener("keydown", (event) => this.handleKeyDown(event));
    this.$root.addEventListener("click", (event) => this.debounce(event));
  }
  handleKeyDown(event) {
    const $target = event.target;
    if (event.key !== " ") {
      return;
    }
    if ($target instanceof HTMLElement && $target.getAttribute("role") === "button") {
      event.preventDefault();
      $target.click();
    }
  }
  debounce(event) {
    if (!this.config.preventDoubleClick) {
      return;
    }
    if (this.debounceFormSubmitTimer) {
      event.preventDefault();
      return false;
    }
    this.debounceFormSubmitTimer = window.setTimeout(() => {
      this.debounceFormSubmitTimer = null;
    }, DEBOUNCE_TIMEOUT_IN_SECONDS * 1e3);
  }
};
Button.moduleName = "govuk-button";
Button.defaults = Object.freeze({
  preventDoubleClick: false
});
Button.schema = Object.freeze({
  properties: {
    preventDoubleClick: {
      type: "boolean"
    }
  }
});

// node_modules/govuk-frontend/dist/govuk/common/closest-attribute-value.mjs
function closestAttributeValue($element, attributeName) {
  const $closestElementWithAttribute = $element.closest(`[${attributeName}]`);
  return $closestElementWithAttribute ? $closestElementWithAttribute.getAttribute(attributeName) : null;
}

// node_modules/govuk-frontend/dist/govuk/components/character-count/character-count.mjs
var CharacterCount = class _CharacterCount extends ConfigurableComponent {
  [configOverride](datasetConfig) {
    let configOverrides = {};
    if ("maxwords" in datasetConfig || "maxlength" in datasetConfig) {
      configOverrides = {
        maxlength: void 0,
        maxwords: void 0
      };
    }
    return configOverrides;
  }
  /**
   * @param {Element | null} $root - HTML element to use for character count
   * @param {CharacterCountConfig} [config] - Character count config
   */
  constructor($root, config = {}) {
    var _ref, _this$config$maxwords;
    super($root, config);
    this.$textarea = void 0;
    this.$visibleCountMessage = void 0;
    this.$screenReaderCountMessage = void 0;
    this.lastInputTimestamp = null;
    this.lastInputValue = "";
    this.valueChecker = null;
    this.i18n = void 0;
    this.maxLength = void 0;
    const $textarea = this.$root.querySelector(".govuk-js-character-count");
    if (!($textarea instanceof HTMLTextAreaElement || $textarea instanceof HTMLInputElement)) {
      throw new ElementError({
        component: _CharacterCount,
        element: $textarea,
        expectedType: "HTMLTextareaElement or HTMLInputElement",
        identifier: "Form field (`.govuk-js-character-count`)"
      });
    }
    const errors = validateConfig(_CharacterCount.schema, this.config);
    if (errors[0]) {
      throw new ConfigError(formatErrorMessage(_CharacterCount, errors[0]));
    }
    this.i18n = new I18n(this.config.i18n, {
      locale: closestAttributeValue(this.$root, "lang")
    });
    this.maxLength = (_ref = (_this$config$maxwords = this.config.maxwords) != null ? _this$config$maxwords : this.config.maxlength) != null ? _ref : Infinity;
    this.$textarea = $textarea;
    const textareaDescriptionId = `${this.$textarea.id}-info`;
    const $textareaDescription = document.getElementById(textareaDescriptionId);
    if (!$textareaDescription) {
      throw new ElementError({
        component: _CharacterCount,
        element: $textareaDescription,
        identifier: `Count message (\`id="${textareaDescriptionId}"\`)`
      });
    }
    this.$errorMessage = this.$root.querySelector(".govuk-error-message");
    if (`${$textareaDescription.textContent}`.match(/^\s*$/)) {
      $textareaDescription.textContent = this.i18n.t("textareaDescription", {
        count: this.maxLength
      });
    }
    this.$textarea.insertAdjacentElement("afterend", $textareaDescription);
    const $screenReaderCountMessage = document.createElement("div");
    $screenReaderCountMessage.className = "govuk-character-count__sr-status govuk-visually-hidden";
    $screenReaderCountMessage.setAttribute("aria-live", "polite");
    this.$screenReaderCountMessage = $screenReaderCountMessage;
    $textareaDescription.insertAdjacentElement("afterend", $screenReaderCountMessage);
    const $visibleCountMessage = document.createElement("div");
    $visibleCountMessage.className = $textareaDescription.className;
    $visibleCountMessage.classList.add("govuk-character-count__status");
    $visibleCountMessage.setAttribute("aria-hidden", "true");
    this.$visibleCountMessage = $visibleCountMessage;
    $textareaDescription.insertAdjacentElement("afterend", $visibleCountMessage);
    $textareaDescription.classList.add("govuk-visually-hidden");
    this.$textarea.removeAttribute("maxlength");
    this.bindChangeEvents();
    window.addEventListener("pageshow", () => this.updateCountMessage());
    this.updateCountMessage();
  }
  bindChangeEvents() {
    this.$textarea.addEventListener("keyup", () => this.handleKeyUp());
    this.$textarea.addEventListener("focus", () => this.handleFocus());
    this.$textarea.addEventListener("blur", () => this.handleBlur());
  }
  handleKeyUp() {
    this.updateVisibleCountMessage();
    this.lastInputTimestamp = Date.now();
  }
  handleFocus() {
    this.valueChecker = window.setInterval(() => {
      if (!this.lastInputTimestamp || Date.now() - 500 >= this.lastInputTimestamp) {
        this.updateIfValueChanged();
      }
    }, 1e3);
  }
  handleBlur() {
    if (this.valueChecker) {
      window.clearInterval(this.valueChecker);
    }
  }
  updateIfValueChanged() {
    if (this.$textarea.value !== this.lastInputValue) {
      this.lastInputValue = this.$textarea.value;
      this.updateCountMessage();
    }
  }
  updateCountMessage() {
    this.updateVisibleCountMessage();
    this.updateScreenReaderCountMessage();
  }
  updateVisibleCountMessage() {
    const remainingNumber = this.maxLength - this.count(this.$textarea.value);
    const isError = remainingNumber < 0;
    this.$visibleCountMessage.classList.toggle("govuk-character-count__message--disabled", !this.isOverThreshold());
    if (!this.$errorMessage) {
      this.$textarea.classList.toggle("govuk-textarea--error", isError);
    }
    this.$visibleCountMessage.classList.toggle("govuk-error-message", isError);
    this.$visibleCountMessage.classList.toggle("govuk-hint", !isError);
    this.$visibleCountMessage.textContent = this.getCountMessage();
  }
  updateScreenReaderCountMessage() {
    if (this.isOverThreshold()) {
      this.$screenReaderCountMessage.removeAttribute("aria-hidden");
    } else {
      this.$screenReaderCountMessage.setAttribute("aria-hidden", "true");
    }
    this.$screenReaderCountMessage.textContent = this.getCountMessage();
  }
  count(text) {
    if (this.config.maxwords) {
      var _text$match;
      const tokens = (_text$match = text.match(/\S+/g)) != null ? _text$match : [];
      return tokens.length;
    }
    return text.length;
  }
  getCountMessage() {
    const remainingNumber = this.maxLength - this.count(this.$textarea.value);
    const countType = this.config.maxwords ? "words" : "characters";
    return this.formatCountMessage(remainingNumber, countType);
  }
  formatCountMessage(remainingNumber, countType) {
    if (remainingNumber === 0) {
      return this.i18n.t(`${countType}AtLimit`);
    }
    const translationKeySuffix = remainingNumber < 0 ? "OverLimit" : "UnderLimit";
    return this.i18n.t(`${countType}${translationKeySuffix}`, {
      count: Math.abs(remainingNumber)
    });
  }
  isOverThreshold() {
    if (!this.config.threshold) {
      return true;
    }
    const currentLength = this.count(this.$textarea.value);
    const maxLength = this.maxLength;
    const thresholdValue = maxLength * this.config.threshold / 100;
    return thresholdValue <= currentLength;
  }
};
CharacterCount.moduleName = "govuk-character-count";
CharacterCount.defaults = Object.freeze({
  threshold: 0,
  i18n: {
    charactersUnderLimit: {
      one: "You have %{count} character remaining",
      other: "You have %{count} characters remaining"
    },
    charactersAtLimit: "You have 0 characters remaining",
    charactersOverLimit: {
      one: "You have %{count} character too many",
      other: "You have %{count} characters too many"
    },
    wordsUnderLimit: {
      one: "You have %{count} word remaining",
      other: "You have %{count} words remaining"
    },
    wordsAtLimit: "You have 0 words remaining",
    wordsOverLimit: {
      one: "You have %{count} word too many",
      other: "You have %{count} words too many"
    },
    textareaDescription: {
      other: ""
    }
  }
});
CharacterCount.schema = Object.freeze({
  properties: {
    i18n: {
      type: "object"
    },
    maxwords: {
      type: "number"
    },
    maxlength: {
      type: "number"
    },
    threshold: {
      type: "number"
    }
  },
  anyOf: [{
    required: ["maxwords"],
    errorMessage: 'Either "maxlength" or "maxwords" must be provided'
  }, {
    required: ["maxlength"],
    errorMessage: 'Either "maxlength" or "maxwords" must be provided'
  }]
});

// node_modules/govuk-frontend/dist/govuk/components/checkboxes/checkboxes.mjs
var Checkboxes = class _Checkboxes extends Component {
  /**
   * Checkboxes can be associated with a 'conditionally revealed' content block
   * – for example, a checkbox for 'Phone' could reveal an additional form field
   * for the user to enter their phone number.
   *
   * These associations are made using a `data-aria-controls` attribute, which
   * is promoted to an aria-controls attribute during initialisation.
   *
   * We also need to restore the state of any conditional reveals on the page
   * (for example if the user has navigated back), and set up event handlers to
   * keep the reveal in sync with the checkbox state.
   *
   * @param {Element | null} $root - HTML element to use for checkboxes
   */
  constructor($root) {
    super($root);
    this.$inputs = void 0;
    const $inputs = this.$root.querySelectorAll('input[type="checkbox"]');
    if (!$inputs.length) {
      throw new ElementError({
        component: _Checkboxes,
        identifier: 'Form inputs (`<input type="checkbox">`)'
      });
    }
    this.$inputs = $inputs;
    this.$inputs.forEach(($input) => {
      const targetId = $input.getAttribute("data-aria-controls");
      if (!targetId) {
        return;
      }
      if (!document.getElementById(targetId)) {
        throw new ElementError({
          component: _Checkboxes,
          identifier: `Conditional reveal (\`id="${targetId}"\`)`
        });
      }
      $input.setAttribute("aria-controls", targetId);
      $input.removeAttribute("data-aria-controls");
    });
    window.addEventListener("pageshow", () => this.syncAllConditionalReveals());
    this.syncAllConditionalReveals();
    this.$root.addEventListener("click", (event) => this.handleClick(event));
  }
  syncAllConditionalReveals() {
    this.$inputs.forEach(($input) => this.syncConditionalRevealWithInputState($input));
  }
  syncConditionalRevealWithInputState($input) {
    const targetId = $input.getAttribute("aria-controls");
    if (!targetId) {
      return;
    }
    const $target = document.getElementById(targetId);
    if ($target != null && $target.classList.contains("govuk-checkboxes__conditional")) {
      const inputIsChecked = $input.checked;
      $input.setAttribute("aria-expanded", inputIsChecked.toString());
      $target.classList.toggle("govuk-checkboxes__conditional--hidden", !inputIsChecked);
    }
  }
  unCheckAllInputsExcept($input) {
    const allInputsWithSameName = document.querySelectorAll(`input[type="checkbox"][name="${$input.name}"]`);
    allInputsWithSameName.forEach(($inputWithSameName) => {
      const hasSameFormOwner = $input.form === $inputWithSameName.form;
      if (hasSameFormOwner && $inputWithSameName !== $input) {
        $inputWithSameName.checked = false;
        this.syncConditionalRevealWithInputState($inputWithSameName);
      }
    });
  }
  unCheckExclusiveInputs($input) {
    const allInputsWithSameNameAndExclusiveBehaviour = document.querySelectorAll(`input[data-behaviour="exclusive"][type="checkbox"][name="${$input.name}"]`);
    allInputsWithSameNameAndExclusiveBehaviour.forEach(($exclusiveInput) => {
      const hasSameFormOwner = $input.form === $exclusiveInput.form;
      if (hasSameFormOwner) {
        $exclusiveInput.checked = false;
        this.syncConditionalRevealWithInputState($exclusiveInput);
      }
    });
  }
  handleClick(event) {
    const $clickedInput = event.target;
    if (!($clickedInput instanceof HTMLInputElement) || $clickedInput.type !== "checkbox") {
      return;
    }
    const hasAriaControls = $clickedInput.getAttribute("aria-controls");
    if (hasAriaControls) {
      this.syncConditionalRevealWithInputState($clickedInput);
    }
    if (!$clickedInput.checked) {
      return;
    }
    const hasBehaviourExclusive = $clickedInput.getAttribute("data-behaviour") === "exclusive";
    if (hasBehaviourExclusive) {
      this.unCheckAllInputsExcept($clickedInput);
    } else {
      this.unCheckExclusiveInputs($clickedInput);
    }
  }
};
Checkboxes.moduleName = "govuk-checkboxes";

// node_modules/govuk-frontend/dist/govuk/components/error-summary/error-summary.mjs
var ErrorSummary = class extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - HTML element to use for error summary
   * @param {ErrorSummaryConfig} [config] - Error summary config
   */
  constructor($root, config = {}) {
    super($root, config);
    if (!this.config.disableAutoFocus) {
      setFocus(this.$root);
    }
    this.$root.addEventListener("click", (event) => this.handleClick(event));
  }
  handleClick(event) {
    const $target = event.target;
    if ($target && this.focusTarget($target)) {
      event.preventDefault();
    }
  }
  focusTarget($target) {
    if (!($target instanceof HTMLAnchorElement)) {
      return false;
    }
    const inputId = getFragmentFromUrl($target.href);
    if (!inputId) {
      return false;
    }
    const $input = document.getElementById(inputId);
    if (!$input) {
      return false;
    }
    const $legendOrLabel = this.getAssociatedLegendOrLabel($input);
    if (!$legendOrLabel) {
      return false;
    }
    $legendOrLabel.scrollIntoView();
    $input.focus({
      preventScroll: true
    });
    return true;
  }
  getAssociatedLegendOrLabel($input) {
    var _document$querySelect;
    const $fieldset = $input.closest("fieldset");
    if ($fieldset) {
      const $legends = $fieldset.getElementsByTagName("legend");
      if ($legends.length) {
        const $candidateLegend = $legends[0];
        if ($input instanceof HTMLInputElement && ($input.type === "checkbox" || $input.type === "radio")) {
          return $candidateLegend;
        }
        const legendTop = $candidateLegend.getBoundingClientRect().top;
        const inputRect = $input.getBoundingClientRect();
        if (inputRect.height && window.innerHeight) {
          const inputBottom = inputRect.top + inputRect.height;
          if (inputBottom - legendTop < window.innerHeight / 2) {
            return $candidateLegend;
          }
        }
      }
    }
    return (_document$querySelect = document.querySelector(`label[for='${$input.getAttribute("id")}']`)) != null ? _document$querySelect : $input.closest("label");
  }
};
ErrorSummary.moduleName = "govuk-error-summary";
ErrorSummary.defaults = Object.freeze({
  disableAutoFocus: false
});
ErrorSummary.schema = Object.freeze({
  properties: {
    disableAutoFocus: {
      type: "boolean"
    }
  }
});

// node_modules/govuk-frontend/dist/govuk/components/exit-this-page/exit-this-page.mjs
var ExitThisPage = class _ExitThisPage extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - HTML element that wraps the Exit This Page button
   * @param {ExitThisPageConfig} [config] - Exit This Page config
   */
  constructor($root, config = {}) {
    super($root, config);
    this.i18n = void 0;
    this.$button = void 0;
    this.$skiplinkButton = null;
    this.$updateSpan = null;
    this.$indicatorContainer = null;
    this.$overlay = null;
    this.keypressCounter = 0;
    this.lastKeyWasModified = false;
    this.timeoutTime = 5e3;
    this.keypressTimeoutId = null;
    this.timeoutMessageId = null;
    const $button = this.$root.querySelector(".govuk-exit-this-page__button");
    if (!($button instanceof HTMLAnchorElement)) {
      throw new ElementError({
        component: _ExitThisPage,
        element: $button,
        expectedType: "HTMLAnchorElement",
        identifier: "Button (`.govuk-exit-this-page__button`)"
      });
    }
    this.i18n = new I18n(this.config.i18n);
    this.$button = $button;
    const $skiplinkButton = document.querySelector(".govuk-js-exit-this-page-skiplink");
    if ($skiplinkButton instanceof HTMLAnchorElement) {
      this.$skiplinkButton = $skiplinkButton;
    }
    this.buildIndicator();
    this.initUpdateSpan();
    this.initButtonClickHandler();
    if (!("govukFrontendExitThisPageKeypress" in document.body.dataset)) {
      document.addEventListener("keyup", this.handleKeypress.bind(this), true);
      document.body.dataset.govukFrontendExitThisPageKeypress = "true";
    }
    window.addEventListener("pageshow", this.resetPage.bind(this));
  }
  initUpdateSpan() {
    this.$updateSpan = document.createElement("span");
    this.$updateSpan.setAttribute("role", "status");
    this.$updateSpan.className = "govuk-visually-hidden";
    this.$root.appendChild(this.$updateSpan);
  }
  initButtonClickHandler() {
    this.$button.addEventListener("click", this.handleClick.bind(this));
    if (this.$skiplinkButton) {
      this.$skiplinkButton.addEventListener("click", this.handleClick.bind(this));
    }
  }
  buildIndicator() {
    this.$indicatorContainer = document.createElement("div");
    this.$indicatorContainer.className = "govuk-exit-this-page__indicator";
    this.$indicatorContainer.setAttribute("aria-hidden", "true");
    for (let i = 0; i < 3; i++) {
      const $indicator = document.createElement("div");
      $indicator.className = "govuk-exit-this-page__indicator-light";
      this.$indicatorContainer.appendChild($indicator);
    }
    this.$button.appendChild(this.$indicatorContainer);
  }
  updateIndicator() {
    if (!this.$indicatorContainer) {
      return;
    }
    this.$indicatorContainer.classList.toggle("govuk-exit-this-page__indicator--visible", this.keypressCounter > 0);
    const $indicators = this.$indicatorContainer.querySelectorAll(".govuk-exit-this-page__indicator-light");
    $indicators.forEach(($indicator, index) => {
      $indicator.classList.toggle("govuk-exit-this-page__indicator-light--on", index < this.keypressCounter);
    });
  }
  exitPage() {
    if (!this.$updateSpan) {
      return;
    }
    this.$updateSpan.textContent = "";
    document.body.classList.add("govuk-exit-this-page-hide-content");
    this.$overlay = document.createElement("div");
    this.$overlay.className = "govuk-exit-this-page-overlay";
    this.$overlay.setAttribute("role", "alert");
    document.body.appendChild(this.$overlay);
    this.$overlay.textContent = this.i18n.t("activated");
    window.location.href = this.$button.href;
  }
  handleClick(event) {
    event.preventDefault();
    this.exitPage();
  }
  handleKeypress(event) {
    if (!this.$updateSpan) {
      return;
    }
    if (event.key === "Shift" && !this.lastKeyWasModified) {
      this.keypressCounter += 1;
      this.updateIndicator();
      if (this.timeoutMessageId) {
        window.clearTimeout(this.timeoutMessageId);
        this.timeoutMessageId = null;
      }
      if (this.keypressCounter >= 3) {
        this.keypressCounter = 0;
        if (this.keypressTimeoutId) {
          window.clearTimeout(this.keypressTimeoutId);
          this.keypressTimeoutId = null;
        }
        this.exitPage();
      } else {
        if (this.keypressCounter === 1) {
          this.$updateSpan.textContent = this.i18n.t("pressTwoMoreTimes");
        } else {
          this.$updateSpan.textContent = this.i18n.t("pressOneMoreTime");
        }
      }
      this.setKeypressTimer();
    } else if (this.keypressTimeoutId) {
      this.resetKeypressTimer();
    }
    this.lastKeyWasModified = event.shiftKey;
  }
  setKeypressTimer() {
    if (this.keypressTimeoutId) {
      window.clearTimeout(this.keypressTimeoutId);
    }
    this.keypressTimeoutId = window.setTimeout(this.resetKeypressTimer.bind(this), this.timeoutTime);
  }
  resetKeypressTimer() {
    if (!this.$updateSpan) {
      return;
    }
    if (this.keypressTimeoutId) {
      window.clearTimeout(this.keypressTimeoutId);
      this.keypressTimeoutId = null;
    }
    const $updateSpan = this.$updateSpan;
    this.keypressCounter = 0;
    $updateSpan.textContent = this.i18n.t("timedOut");
    this.timeoutMessageId = window.setTimeout(() => {
      $updateSpan.textContent = "";
    }, this.timeoutTime);
    this.updateIndicator();
  }
  resetPage() {
    document.body.classList.remove("govuk-exit-this-page-hide-content");
    if (this.$overlay) {
      this.$overlay.remove();
      this.$overlay = null;
    }
    if (this.$updateSpan) {
      this.$updateSpan.setAttribute("role", "status");
      this.$updateSpan.textContent = "";
    }
    this.updateIndicator();
    if (this.keypressTimeoutId) {
      window.clearTimeout(this.keypressTimeoutId);
    }
    if (this.timeoutMessageId) {
      window.clearTimeout(this.timeoutMessageId);
    }
  }
};
ExitThisPage.moduleName = "govuk-exit-this-page";
ExitThisPage.defaults = Object.freeze({
  i18n: {
    activated: "Loading.",
    timedOut: "Exit this page expired.",
    pressTwoMoreTimes: "Shift, press 2 more times to exit.",
    pressOneMoreTime: "Shift, press 1 more time to exit."
  }
});
ExitThisPage.schema = Object.freeze({
  properties: {
    i18n: {
      type: "object"
    }
  }
});

// node_modules/govuk-frontend/dist/govuk/components/file-upload/file-upload.mjs
var FileUpload = class _FileUpload extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - File input element
   * @param {FileUploadConfig} [config] - File Upload config
   */
  constructor($root, config = {}) {
    super($root, config);
    this.$input = void 0;
    this.$button = void 0;
    this.$status = void 0;
    this.i18n = void 0;
    this.id = void 0;
    this.$announcements = void 0;
    this.enteredAnotherElement = void 0;
    const $input = this.$root.querySelector("input");
    if ($input === null) {
      throw new ElementError({
        component: _FileUpload,
        identifier: 'File inputs (`<input type="file">`)'
      });
    }
    if ($input.type !== "file") {
      throw new ElementError(formatErrorMessage(_FileUpload, 'File input (`<input type="file">`) attribute (`type`) is not `file`'));
    }
    this.$input = $input;
    this.$input.setAttribute("hidden", "true");
    if (!this.$input.id) {
      throw new ElementError({
        component: _FileUpload,
        identifier: 'File input (`<input type="file">`) attribute (`id`)'
      });
    }
    this.id = this.$input.id;
    this.i18n = new I18n(this.config.i18n, {
      locale: closestAttributeValue(this.$root, "lang")
    });
    const $label = this.findLabel();
    if (!$label.id) {
      $label.id = `${this.id}-label`;
    }
    this.$input.id = `${this.id}-input`;
    const $button = document.createElement("button");
    $button.classList.add("govuk-file-upload-button");
    $button.type = "button";
    $button.id = this.id;
    $button.classList.add("govuk-file-upload-button--empty");
    const ariaDescribedBy = this.$input.getAttribute("aria-describedby");
    if (ariaDescribedBy) {
      $button.setAttribute("aria-describedby", ariaDescribedBy);
    }
    const $status = document.createElement("span");
    $status.className = "govuk-body govuk-file-upload-button__status";
    $status.setAttribute("aria-live", "polite");
    $status.innerText = this.i18n.t("noFileChosen");
    $button.appendChild($status);
    const commaSpan = document.createElement("span");
    commaSpan.className = "govuk-visually-hidden";
    commaSpan.innerText = ", ";
    commaSpan.id = `${this.id}-comma`;
    $button.appendChild(commaSpan);
    const containerSpan = document.createElement("span");
    containerSpan.className = "govuk-file-upload-button__pseudo-button-container";
    const buttonSpan = document.createElement("span");
    buttonSpan.className = "govuk-button govuk-button--secondary govuk-file-upload-button__pseudo-button";
    buttonSpan.innerText = this.i18n.t("chooseFilesButton");
    containerSpan.appendChild(buttonSpan);
    containerSpan.insertAdjacentText("beforeend", " ");
    const instructionSpan = document.createElement("span");
    instructionSpan.className = "govuk-body govuk-file-upload-button__instruction";
    instructionSpan.innerText = this.i18n.t("dropInstruction");
    containerSpan.appendChild(instructionSpan);
    $button.appendChild(containerSpan);
    $button.setAttribute("aria-labelledby", `${$label.id} ${commaSpan.id} ${$button.id}`);
    $button.addEventListener("click", this.onClick.bind(this));
    $button.addEventListener("dragover", (event) => {
      event.preventDefault();
    });
    this.$root.insertAdjacentElement("afterbegin", $button);
    this.$input.setAttribute("tabindex", "-1");
    this.$input.setAttribute("aria-hidden", "true");
    this.$button = $button;
    this.$status = $status;
    this.$input.addEventListener("change", this.onChange.bind(this));
    this.updateDisabledState();
    this.observeDisabledState();
    this.$announcements = document.createElement("span");
    this.$announcements.classList.add("govuk-file-upload-announcements");
    this.$announcements.classList.add("govuk-visually-hidden");
    this.$announcements.setAttribute("aria-live", "assertive");
    this.$root.insertAdjacentElement("afterend", this.$announcements);
    this.$button.addEventListener("drop", this.onDrop.bind(this));
    document.addEventListener("dragenter", this.updateDropzoneVisibility.bind(this));
    document.addEventListener("dragenter", () => {
      this.enteredAnotherElement = true;
    });
    document.addEventListener("dragleave", () => {
      if (!this.enteredAnotherElement && !this.$button.disabled) {
        this.hideDraggingState();
        this.$announcements.innerText = this.i18n.t("leftDropZone");
      }
      this.enteredAnotherElement = false;
    });
  }
  updateDropzoneVisibility(event) {
    if (this.$button.disabled) return;
    if (event.target instanceof Node) {
      if (this.$root.contains(event.target)) {
        if (event.dataTransfer && isContainingFiles(event.dataTransfer)) {
          if (!this.$button.classList.contains("govuk-file-upload-button--dragging")) {
            this.showDraggingState();
            this.$announcements.innerText = this.i18n.t("enteredDropZone");
          }
        }
      } else {
        if (this.$button.classList.contains("govuk-file-upload-button--dragging")) {
          this.hideDraggingState();
          this.$announcements.innerText = this.i18n.t("leftDropZone");
        }
      }
    }
  }
  showDraggingState() {
    this.$button.classList.add("govuk-file-upload-button--dragging");
  }
  hideDraggingState() {
    this.$button.classList.remove("govuk-file-upload-button--dragging");
  }
  onDrop(event) {
    event.preventDefault();
    if (event.dataTransfer && isContainingFiles(event.dataTransfer)) {
      this.$input.files = event.dataTransfer.files;
      this.$input.dispatchEvent(new CustomEvent("change"));
      this.hideDraggingState();
    }
  }
  onChange() {
    const fileCount = this.$input.files.length;
    if (fileCount === 0) {
      this.$status.innerText = this.i18n.t("noFileChosen");
      this.$button.classList.add("govuk-file-upload-button--empty");
    } else {
      if (fileCount === 1) {
        this.$status.innerText = this.$input.files[0].name;
      } else {
        this.$status.innerText = this.i18n.t("multipleFilesChosen", {
          count: fileCount
        });
      }
      this.$button.classList.remove("govuk-file-upload-button--empty");
    }
  }
  findLabel() {
    const $label = document.querySelector(`label[for="${this.$input.id}"]`);
    if (!$label) {
      throw new ElementError({
        component: _FileUpload,
        identifier: `Field label (\`<label for=${this.$input.id}>\`)`
      });
    }
    return $label;
  }
  onClick() {
    this.$input.click();
  }
  observeDisabledState() {
    const observer = new MutationObserver((mutationList) => {
      for (const mutation of mutationList) {
        if (mutation.type === "attributes" && mutation.attributeName === "disabled") {
          this.updateDisabledState();
        }
      }
    });
    observer.observe(this.$input, {
      attributes: true
    });
  }
  updateDisabledState() {
    this.$button.disabled = this.$input.disabled;
    this.$root.classList.toggle("govuk-drop-zone--disabled", this.$button.disabled);
  }
};
FileUpload.moduleName = "govuk-file-upload";
FileUpload.defaults = Object.freeze({
  i18n: {
    chooseFilesButton: "Choose file",
    dropInstruction: "or drop file",
    noFileChosen: "No file chosen",
    multipleFilesChosen: {
      one: "%{count} file chosen",
      other: "%{count} files chosen"
    },
    enteredDropZone: "Entered drop zone",
    leftDropZone: "Left drop zone"
  }
});
FileUpload.schema = Object.freeze({
  properties: {
    i18n: {
      type: "object"
    }
  }
});
function isContainingFiles(dataTransfer) {
  const hasNoTypesInfo = dataTransfer.types.length === 0;
  const isDraggingFiles = dataTransfer.types.some((type) => type === "Files");
  return hasNoTypesInfo || isDraggingFiles;
}

// node_modules/govuk-frontend/dist/govuk/components/header/header.mjs
var Header = class _Header extends Component {
  /**
   * Apply a matchMedia for desktop which will trigger a state sync if the
   * browser viewport moves between states.
   *
   * @param {Element | null} $root - HTML element to use for header
   */
  constructor($root) {
    super($root);
    this.$menuButton = void 0;
    this.$menu = void 0;
    this.menuIsOpen = false;
    this.mql = null;
    const $menuButton = this.$root.querySelector(".govuk-js-header-toggle");
    if (!$menuButton) {
      return this;
    }
    this.$root.classList.add("govuk-header--with-js-navigation");
    const menuId = $menuButton.getAttribute("aria-controls");
    if (!menuId) {
      throw new ElementError({
        component: _Header,
        identifier: 'Navigation button (`<button class="govuk-js-header-toggle">`) attribute (`aria-controls`)'
      });
    }
    const $menu = document.getElementById(menuId);
    if (!$menu) {
      throw new ElementError({
        component: _Header,
        element: $menu,
        identifier: `Navigation (\`<ul id="${menuId}">\`)`
      });
    }
    this.$menu = $menu;
    this.$menuButton = $menuButton;
    this.setupResponsiveChecks();
    this.$menuButton.addEventListener("click", () => this.handleMenuButtonClick());
  }
  setupResponsiveChecks() {
    const breakpoint = getBreakpoint("desktop");
    if (!breakpoint.value) {
      throw new ElementError({
        component: _Header,
        identifier: `CSS custom property (\`${breakpoint.property}\`) on pseudo-class \`:root\``
      });
    }
    this.mql = window.matchMedia(`(min-width: ${breakpoint.value})`);
    if ("addEventListener" in this.mql) {
      this.mql.addEventListener("change", () => this.checkMode());
    } else {
      this.mql.addListener(() => this.checkMode());
    }
    this.checkMode();
  }
  checkMode() {
    if (!this.mql || !this.$menu || !this.$menuButton) {
      return;
    }
    if (this.mql.matches) {
      this.$menu.removeAttribute("hidden");
      this.$menuButton.setAttribute("hidden", "");
    } else {
      this.$menuButton.removeAttribute("hidden");
      this.$menuButton.setAttribute("aria-expanded", this.menuIsOpen.toString());
      if (this.menuIsOpen) {
        this.$menu.removeAttribute("hidden");
      } else {
        this.$menu.setAttribute("hidden", "");
      }
    }
  }
  handleMenuButtonClick() {
    this.menuIsOpen = !this.menuIsOpen;
    this.checkMode();
  }
};
Header.moduleName = "govuk-header";

// node_modules/govuk-frontend/dist/govuk/components/notification-banner/notification-banner.mjs
var NotificationBanner = class extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - HTML element to use for notification banner
   * @param {NotificationBannerConfig} [config] - Notification banner config
   */
  constructor($root, config = {}) {
    super($root, config);
    if (this.$root.getAttribute("role") === "alert" && !this.config.disableAutoFocus) {
      setFocus(this.$root);
    }
  }
};
NotificationBanner.moduleName = "govuk-notification-banner";
NotificationBanner.defaults = Object.freeze({
  disableAutoFocus: false
});
NotificationBanner.schema = Object.freeze({
  properties: {
    disableAutoFocus: {
      type: "boolean"
    }
  }
});

// node_modules/govuk-frontend/dist/govuk/components/password-input/password-input.mjs
var PasswordInput = class _PasswordInput extends ConfigurableComponent {
  /**
   * @param {Element | null} $root - HTML element to use for password input
   * @param {PasswordInputConfig} [config] - Password input config
   */
  constructor($root, config = {}) {
    super($root, config);
    this.i18n = void 0;
    this.$input = void 0;
    this.$showHideButton = void 0;
    this.$screenReaderStatusMessage = void 0;
    const $input = this.$root.querySelector(".govuk-js-password-input-input");
    if (!($input instanceof HTMLInputElement)) {
      throw new ElementError({
        component: _PasswordInput,
        element: $input,
        expectedType: "HTMLInputElement",
        identifier: "Form field (`.govuk-js-password-input-input`)"
      });
    }
    if ($input.type !== "password") {
      throw new ElementError("Password input: Form field (`.govuk-js-password-input-input`) must be of type `password`.");
    }
    const $showHideButton = this.$root.querySelector(".govuk-js-password-input-toggle");
    if (!($showHideButton instanceof HTMLButtonElement)) {
      throw new ElementError({
        component: _PasswordInput,
        element: $showHideButton,
        expectedType: "HTMLButtonElement",
        identifier: "Button (`.govuk-js-password-input-toggle`)"
      });
    }
    if ($showHideButton.type !== "button") {
      throw new ElementError("Password input: Button (`.govuk-js-password-input-toggle`) must be of type `button`.");
    }
    this.$input = $input;
    this.$showHideButton = $showHideButton;
    this.i18n = new I18n(this.config.i18n, {
      locale: closestAttributeValue(this.$root, "lang")
    });
    this.$showHideButton.removeAttribute("hidden");
    const $screenReaderStatusMessage = document.createElement("div");
    $screenReaderStatusMessage.className = "govuk-password-input__sr-status govuk-visually-hidden";
    $screenReaderStatusMessage.setAttribute("aria-live", "polite");
    this.$screenReaderStatusMessage = $screenReaderStatusMessage;
    this.$input.insertAdjacentElement("afterend", $screenReaderStatusMessage);
    this.$showHideButton.addEventListener("click", this.toggle.bind(this));
    if (this.$input.form) {
      this.$input.form.addEventListener("submit", () => this.hide());
    }
    window.addEventListener("pageshow", (event) => {
      if (event.persisted && this.$input.type !== "password") {
        this.hide();
      }
    });
    this.hide();
  }
  toggle(event) {
    event.preventDefault();
    if (this.$input.type === "password") {
      this.show();
      return;
    }
    this.hide();
  }
  show() {
    this.setType("text");
  }
  hide() {
    this.setType("password");
  }
  setType(type) {
    if (type === this.$input.type) {
      return;
    }
    this.$input.setAttribute("type", type);
    const isHidden = type === "password";
    const prefixButton = isHidden ? "show" : "hide";
    const prefixStatus = isHidden ? "passwordHidden" : "passwordShown";
    this.$showHideButton.innerText = this.i18n.t(`${prefixButton}Password`);
    this.$showHideButton.setAttribute("aria-label", this.i18n.t(`${prefixButton}PasswordAriaLabel`));
    this.$screenReaderStatusMessage.innerText = this.i18n.t(`${prefixStatus}Announcement`);
  }
};
PasswordInput.moduleName = "govuk-password-input";
PasswordInput.defaults = Object.freeze({
  i18n: {
    showPassword: "Show",
    hidePassword: "Hide",
    showPasswordAriaLabel: "Show password",
    hidePasswordAriaLabel: "Hide password",
    passwordShownAnnouncement: "Your password is visible",
    passwordHiddenAnnouncement: "Your password is hidden"
  }
});
PasswordInput.schema = Object.freeze({
  properties: {
    i18n: {
      type: "object"
    }
  }
});

// node_modules/govuk-frontend/dist/govuk/components/radios/radios.mjs
var Radios = class _Radios extends Component {
  /**
   * Radios can be associated with a 'conditionally revealed' content block –
   * for example, a radio for 'Phone' could reveal an additional form field for
   * the user to enter their phone number.
   *
   * These associations are made using a `data-aria-controls` attribute, which
   * is promoted to an aria-controls attribute during initialisation.
   *
   * We also need to restore the state of any conditional reveals on the page
   * (for example if the user has navigated back), and set up event handlers to
   * keep the reveal in sync with the radio state.
   *
   * @param {Element | null} $root - HTML element to use for radios
   */
  constructor($root) {
    super($root);
    this.$inputs = void 0;
    const $inputs = this.$root.querySelectorAll('input[type="radio"]');
    if (!$inputs.length) {
      throw new ElementError({
        component: _Radios,
        identifier: 'Form inputs (`<input type="radio">`)'
      });
    }
    this.$inputs = $inputs;
    this.$inputs.forEach(($input) => {
      const targetId = $input.getAttribute("data-aria-controls");
      if (!targetId) {
        return;
      }
      if (!document.getElementById(targetId)) {
        throw new ElementError({
          component: _Radios,
          identifier: `Conditional reveal (\`id="${targetId}"\`)`
        });
      }
      $input.setAttribute("aria-controls", targetId);
      $input.removeAttribute("data-aria-controls");
    });
    window.addEventListener("pageshow", () => this.syncAllConditionalReveals());
    this.syncAllConditionalReveals();
    this.$root.addEventListener("click", (event) => this.handleClick(event));
  }
  syncAllConditionalReveals() {
    this.$inputs.forEach(($input) => this.syncConditionalRevealWithInputState($input));
  }
  syncConditionalRevealWithInputState($input) {
    const targetId = $input.getAttribute("aria-controls");
    if (!targetId) {
      return;
    }
    const $target = document.getElementById(targetId);
    if ($target != null && $target.classList.contains("govuk-radios__conditional")) {
      const inputIsChecked = $input.checked;
      $input.setAttribute("aria-expanded", inputIsChecked.toString());
      $target.classList.toggle("govuk-radios__conditional--hidden", !inputIsChecked);
    }
  }
  handleClick(event) {
    const $clickedInput = event.target;
    if (!($clickedInput instanceof HTMLInputElement) || $clickedInput.type !== "radio") {
      return;
    }
    const $allInputs = document.querySelectorAll('input[type="radio"][aria-controls]');
    const $clickedInputForm = $clickedInput.form;
    const $clickedInputName = $clickedInput.name;
    $allInputs.forEach(($input) => {
      const hasSameFormOwner = $input.form === $clickedInputForm;
      const hasSameName = $input.name === $clickedInputName;
      if (hasSameName && hasSameFormOwner) {
        this.syncConditionalRevealWithInputState($input);
      }
    });
  }
};
Radios.moduleName = "govuk-radios";

// node_modules/govuk-frontend/dist/govuk/components/service-navigation/service-navigation.mjs
var ServiceNavigation = class _ServiceNavigation extends Component {
  /**
   * @param {Element | null} $root - HTML element to use for header
   */
  constructor($root) {
    super($root);
    this.$menuButton = void 0;
    this.$menu = void 0;
    this.menuIsOpen = false;
    this.mql = null;
    const $menuButton = this.$root.querySelector(".govuk-js-service-navigation-toggle");
    if (!$menuButton) {
      return this;
    }
    const menuId = $menuButton.getAttribute("aria-controls");
    if (!menuId) {
      throw new ElementError({
        component: _ServiceNavigation,
        identifier: 'Navigation button (`<button class="govuk-js-service-navigation-toggle">`) attribute (`aria-controls`)'
      });
    }
    const $menu = document.getElementById(menuId);
    if (!$menu) {
      throw new ElementError({
        component: _ServiceNavigation,
        element: $menu,
        identifier: `Navigation (\`<ul id="${menuId}">\`)`
      });
    }
    this.$menu = $menu;
    this.$menuButton = $menuButton;
    this.setupResponsiveChecks();
    this.$menuButton.addEventListener("click", () => this.handleMenuButtonClick());
  }
  setupResponsiveChecks() {
    const breakpoint = getBreakpoint("tablet");
    if (!breakpoint.value) {
      throw new ElementError({
        component: _ServiceNavigation,
        identifier: `CSS custom property (\`${breakpoint.property}\`) on pseudo-class \`:root\``
      });
    }
    this.mql = window.matchMedia(`(min-width: ${breakpoint.value})`);
    if ("addEventListener" in this.mql) {
      this.mql.addEventListener("change", () => this.checkMode());
    } else {
      this.mql.addListener(() => this.checkMode());
    }
    this.checkMode();
  }
  checkMode() {
    if (!this.mql || !this.$menu || !this.$menuButton) {
      return;
    }
    if (this.mql.matches) {
      this.$menu.removeAttribute("hidden");
      this.$menuButton.setAttribute("hidden", "");
    } else {
      this.$menuButton.removeAttribute("hidden");
      this.$menuButton.setAttribute("aria-expanded", this.menuIsOpen.toString());
      if (this.menuIsOpen) {
        this.$menu.removeAttribute("hidden");
      } else {
        this.$menu.setAttribute("hidden", "");
      }
    }
  }
  handleMenuButtonClick() {
    this.menuIsOpen = !this.menuIsOpen;
    this.checkMode();
  }
};
ServiceNavigation.moduleName = "govuk-service-navigation";

// node_modules/govuk-frontend/dist/govuk/components/skip-link/skip-link.mjs
var SkipLink = class _SkipLink extends Component {
  /**
   * @param {Element | null} $root - HTML element to use for skip link
   * @throws {ElementError} when $root is not set or the wrong type
   * @throws {ElementError} when $root.hash does not contain a hash
   * @throws {ElementError} when the linked element is missing or the wrong type
   */
  constructor($root) {
    var _this$$root$getAttrib;
    super($root);
    const hash = this.$root.hash;
    const href = (_this$$root$getAttrib = this.$root.getAttribute("href")) != null ? _this$$root$getAttrib : "";
    let url;
    try {
      url = new window.URL(this.$root.href);
    } catch (error) {
      throw new ElementError(`Skip link: Target link (\`href="${href}"\`) is invalid`);
    }
    if (url.origin !== window.location.origin || url.pathname !== window.location.pathname) {
      return;
    }
    const linkedElementId = getFragmentFromUrl(hash);
    if (!linkedElementId) {
      throw new ElementError(`Skip link: Target link (\`href="${href}"\`) has no hash fragment`);
    }
    const $linkedElement = document.getElementById(linkedElementId);
    if (!$linkedElement) {
      throw new ElementError({
        component: _SkipLink,
        element: $linkedElement,
        identifier: `Target content (\`id="${linkedElementId}"\`)`
      });
    }
    this.$root.addEventListener("click", () => setFocus($linkedElement, {
      onBeforeFocus() {
        $linkedElement.classList.add("govuk-skip-link-focused-element");
      },
      onBlur() {
        $linkedElement.classList.remove("govuk-skip-link-focused-element");
      }
    }));
  }
};
SkipLink.elementType = HTMLAnchorElement;
SkipLink.moduleName = "govuk-skip-link";

// node_modules/govuk-frontend/dist/govuk/components/tabs/tabs.mjs
var Tabs = class _Tabs extends Component {
  /**
   * @param {Element | null} $root - HTML element to use for tabs
   */
  constructor($root) {
    super($root);
    this.$tabs = void 0;
    this.$tabList = void 0;
    this.$tabListItems = void 0;
    this.jsHiddenClass = "govuk-tabs__panel--hidden";
    this.changingHash = false;
    this.boundTabClick = void 0;
    this.boundTabKeydown = void 0;
    this.boundOnHashChange = void 0;
    this.mql = null;
    const $tabs = this.$root.querySelectorAll("a.govuk-tabs__tab");
    if (!$tabs.length) {
      throw new ElementError({
        component: _Tabs,
        identifier: 'Links (`<a class="govuk-tabs__tab">`)'
      });
    }
    this.$tabs = $tabs;
    this.boundTabClick = this.onTabClick.bind(this);
    this.boundTabKeydown = this.onTabKeydown.bind(this);
    this.boundOnHashChange = this.onHashChange.bind(this);
    const $tabList = this.$root.querySelector(".govuk-tabs__list");
    const $tabListItems = this.$root.querySelectorAll("li.govuk-tabs__list-item");
    if (!$tabList) {
      throw new ElementError({
        component: _Tabs,
        identifier: 'List (`<ul class="govuk-tabs__list">`)'
      });
    }
    if (!$tabListItems.length) {
      throw new ElementError({
        component: _Tabs,
        identifier: 'List items (`<li class="govuk-tabs__list-item">`)'
      });
    }
    this.$tabList = $tabList;
    this.$tabListItems = $tabListItems;
    this.setupResponsiveChecks();
  }
  setupResponsiveChecks() {
    const breakpoint = getBreakpoint("tablet");
    if (!breakpoint.value) {
      throw new ElementError({
        component: _Tabs,
        identifier: `CSS custom property (\`${breakpoint.property}\`) on pseudo-class \`:root\``
      });
    }
    this.mql = window.matchMedia(`(min-width: ${breakpoint.value})`);
    if ("addEventListener" in this.mql) {
      this.mql.addEventListener("change", () => this.checkMode());
    } else {
      this.mql.addListener(() => this.checkMode());
    }
    this.checkMode();
  }
  checkMode() {
    var _this$mql;
    if ((_this$mql = this.mql) != null && _this$mql.matches) {
      this.setup();
    } else {
      this.teardown();
    }
  }
  setup() {
    var _this$getTab;
    this.$tabList.setAttribute("role", "tablist");
    this.$tabListItems.forEach(($item) => {
      $item.setAttribute("role", "presentation");
    });
    this.$tabs.forEach(($tab) => {
      this.setAttributes($tab);
      $tab.addEventListener("click", this.boundTabClick, true);
      $tab.addEventListener("keydown", this.boundTabKeydown, true);
      this.hideTab($tab);
    });
    const $activeTab = (_this$getTab = this.getTab(window.location.hash)) != null ? _this$getTab : this.$tabs[0];
    this.showTab($activeTab);
    window.addEventListener("hashchange", this.boundOnHashChange, true);
  }
  teardown() {
    this.$tabList.removeAttribute("role");
    this.$tabListItems.forEach(($item) => {
      $item.removeAttribute("role");
    });
    this.$tabs.forEach(($tab) => {
      $tab.removeEventListener("click", this.boundTabClick, true);
      $tab.removeEventListener("keydown", this.boundTabKeydown, true);
      this.unsetAttributes($tab);
    });
    window.removeEventListener("hashchange", this.boundOnHashChange, true);
  }
  onHashChange() {
    const hash = window.location.hash;
    const $tabWithHash = this.getTab(hash);
    if (!$tabWithHash) {
      return;
    }
    if (this.changingHash) {
      this.changingHash = false;
      return;
    }
    const $previousTab = this.getCurrentTab();
    if (!$previousTab) {
      return;
    }
    this.hideTab($previousTab);
    this.showTab($tabWithHash);
    $tabWithHash.focus();
  }
  hideTab($tab) {
    this.unhighlightTab($tab);
    this.hidePanel($tab);
  }
  showTab($tab) {
    this.highlightTab($tab);
    this.showPanel($tab);
  }
  getTab(hash) {
    return this.$root.querySelector(`a.govuk-tabs__tab[href="${hash}"]`);
  }
  setAttributes($tab) {
    const panelId = getFragmentFromUrl($tab.href);
    if (!panelId) {
      return;
    }
    $tab.setAttribute("id", `tab_${panelId}`);
    $tab.setAttribute("role", "tab");
    $tab.setAttribute("aria-controls", panelId);
    $tab.setAttribute("aria-selected", "false");
    $tab.setAttribute("tabindex", "-1");
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.setAttribute("role", "tabpanel");
    $panel.setAttribute("aria-labelledby", $tab.id);
    $panel.classList.add(this.jsHiddenClass);
  }
  unsetAttributes($tab) {
    $tab.removeAttribute("id");
    $tab.removeAttribute("role");
    $tab.removeAttribute("aria-controls");
    $tab.removeAttribute("aria-selected");
    $tab.removeAttribute("tabindex");
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.removeAttribute("role");
    $panel.removeAttribute("aria-labelledby");
    $panel.classList.remove(this.jsHiddenClass);
  }
  onTabClick(event) {
    const $currentTab = this.getCurrentTab();
    const $nextTab = event.currentTarget;
    if (!$currentTab || !($nextTab instanceof HTMLAnchorElement)) {
      return;
    }
    event.preventDefault();
    this.hideTab($currentTab);
    this.showTab($nextTab);
    this.createHistoryEntry($nextTab);
  }
  createHistoryEntry($tab) {
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    const panelId = $panel.id;
    $panel.id = "";
    this.changingHash = true;
    window.location.hash = panelId;
    $panel.id = panelId;
  }
  onTabKeydown(event) {
    switch (event.key) {
      case "ArrowLeft":
      case "Left":
        this.activatePreviousTab();
        event.preventDefault();
        break;
      case "ArrowRight":
      case "Right":
        this.activateNextTab();
        event.preventDefault();
        break;
    }
  }
  activateNextTab() {
    const $currentTab = this.getCurrentTab();
    if (!($currentTab != null && $currentTab.parentElement)) {
      return;
    }
    const $nextTabListItem = $currentTab.parentElement.nextElementSibling;
    if (!$nextTabListItem) {
      return;
    }
    const $nextTab = $nextTabListItem.querySelector("a.govuk-tabs__tab");
    if (!$nextTab) {
      return;
    }
    this.hideTab($currentTab);
    this.showTab($nextTab);
    $nextTab.focus();
    this.createHistoryEntry($nextTab);
  }
  activatePreviousTab() {
    const $currentTab = this.getCurrentTab();
    if (!($currentTab != null && $currentTab.parentElement)) {
      return;
    }
    const $previousTabListItem = $currentTab.parentElement.previousElementSibling;
    if (!$previousTabListItem) {
      return;
    }
    const $previousTab = $previousTabListItem.querySelector("a.govuk-tabs__tab");
    if (!$previousTab) {
      return;
    }
    this.hideTab($currentTab);
    this.showTab($previousTab);
    $previousTab.focus();
    this.createHistoryEntry($previousTab);
  }
  getPanel($tab) {
    const panelId = getFragmentFromUrl($tab.href);
    if (!panelId) {
      return null;
    }
    return this.$root.querySelector(`#${panelId}`);
  }
  showPanel($tab) {
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.classList.remove(this.jsHiddenClass);
  }
  hidePanel($tab) {
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.classList.add(this.jsHiddenClass);
  }
  unhighlightTab($tab) {
    if (!$tab.parentElement) {
      return;
    }
    $tab.setAttribute("aria-selected", "false");
    $tab.parentElement.classList.remove("govuk-tabs__list-item--selected");
    $tab.setAttribute("tabindex", "-1");
  }
  highlightTab($tab) {
    if (!$tab.parentElement) {
      return;
    }
    $tab.setAttribute("aria-selected", "true");
    $tab.parentElement.classList.add("govuk-tabs__list-item--selected");
    $tab.setAttribute("tabindex", "0");
  }
  getCurrentTab() {
    return this.$root.querySelector(".govuk-tabs__list-item--selected a.govuk-tabs__tab");
  }
};
Tabs.moduleName = "govuk-tabs";

// node_modules/govuk-frontend/dist/govuk/init.mjs
function initAll(config) {
  var _config$scope;
  config = typeof config !== "undefined" ? config : {};
  if (!isSupported()) {
    if (config.onError) {
      config.onError(new SupportError(), {
        config
      });
    } else {
      console.log(new SupportError());
    }
    return;
  }
  const components = [[Accordion, config.accordion], [Button, config.button], [CharacterCount, config.characterCount], [Checkboxes], [ErrorSummary, config.errorSummary], [ExitThisPage, config.exitThisPage], [FileUpload, config.fileUpload], [Header], [NotificationBanner, config.notificationBanner], [PasswordInput, config.passwordInput], [Radios], [ServiceNavigation], [SkipLink], [Tabs]];
  const options = {
    scope: (_config$scope = config.scope) != null ? _config$scope : document,
    onError: config.onError
  };
  components.forEach(([Component2, config2]) => {
    createAll(Component2, config2, options);
  });
}
function createAll(Component2, config, createAllOptions) {
  let $scope = document;
  let onError;
  if (typeof createAllOptions === "object") {
    var _createAllOptions$sco;
    createAllOptions = createAllOptions;
    $scope = (_createAllOptions$sco = createAllOptions.scope) != null ? _createAllOptions$sco : $scope;
    onError = createAllOptions.onError;
  }
  if (typeof createAllOptions === "function") {
    onError = createAllOptions;
  }
  if (createAllOptions instanceof HTMLElement) {
    $scope = createAllOptions;
  }
  const $elements = $scope.querySelectorAll(`[data-module="${Component2.moduleName}"]`);
  if (!isSupported()) {
    if (onError) {
      onError(new SupportError(), {
        component: Component2,
        config
      });
    } else {
      console.log(new SupportError());
    }
    return [];
  }
  return Array.from($elements).map(($element) => {
    try {
      return typeof config !== "undefined" ? new Component2($element, config) : new Component2($element);
    } catch (error) {
      if (onError) {
        onError(error, {
          element: $element,
          component: Component2,
          config
        });
      } else {
        console.log(error);
      }
      return null;
    }
  }).filter(Boolean);
}

// app/javascript/moj.js
(function() {
  "use strict";
  var moj2 = {
    Modules: {},
    init: function() {
      for (var x in moj2.Modules) {
        if (typeof moj2.Modules[x].init === "function") {
          moj2.Modules[x].init();
        }
      }
    },
    // safe logging
    log: function(msg) {
      if (window && window.console) {
        window.console.log(msg);
      }
    },
    dir: function(obj) {
      if (window && window.console) {
        window.console.dir(obj);
      }
    }
  };
  window.moj = moj2;
})();

// app/javascript/modules/YesNoRadio.js
moj.Modules.YesNoRadio = {
  $yesContent: document.getElementById("correspondence_contact_requested_yes_content"),
  $noContent: document.getElementById("correspondence_contact_requested_no_content"),
  init: function() {
    const $yes = document.getElementById("correspondence-contact-requested-yes-field");
    const $no = document.getElementById("correspondence-contact-requested-no-field");
    if ($yes) {
      $yes.addEventListener("click", this.showYesContent.bind(this));
      if ($yes.checked) this.showYesContent();
    }
    if ($no) {
      $no.addEventListener("click", this.showNoContent.bind(this));
      if ($no.checked) this.showNoContent();
    }
  },
  showYesContent: function() {
    this.$yesContent.classList.remove("js-hidden");
    this.$noContent.classList.add("js-hidden");
  },
  showNoContent: function() {
    this.$yesContent.classList.add("js-hidden");
    this.$noContent.classList.remove("js-hidden");
  }
};

// app/javascript/modules/CharacterCount.js
var charCount = document.getElementsByClassName("char-counter")[0];
if (charCount) {
  moj.Modules.CharacterCount = {
    $message: document.getElementById("correspondence-message-field") || document.getElementById("correspondence-message-field-error"),
    $liveRegion: document.getElementById("live-region-text"),
    maxChars: Number(charCount.dataset["maxlength"]),
    init: function() {
      this.$message.addEventListener("keydown", this.countCharacters.bind(this));
      this.$message.addEventListener("keyup", this.countCharacters.bind(this));
      this.$message.dispatchEvent(new Event("keydown"));
    },
    countCharacters: function() {
      var text = this.$message.value;
      var realLength = text.length;
      var remaining = this.maxChars - realLength;
      if (remaining < 0) {
        this.$message.classList.add("char-counter--overlimit");
        this.$liveRegion.classList.add("char-counter--overlimit");
        this.$liveRegion.ariaLive = "assertive";
        this.$liveRegion.ariaAtomic = "true";
        this.updateRemaining(remaining);
      } else {
        this.$message.classList.remove("char-counter--overlimit");
        this.$liveRegion.classList.remove("char-counter--overlimit");
        this.$liveRegion.ariaLive = "polite";
        this.$liveRegion.ariaAtomic = "false";
        this.updateRemaining(remaining);
      }
    },
    updateRemaining: function(charsLeft) {
      this.$liveRegion.getElementsByClassName("char-counter-count")[0].textContent = charsLeft;
    }
  };
}

// app/javascript/cookie_banner.js
var cookieBanner = document.querySelector(".govuk-cookie-banner");
if (cookieBanner) {
  hideButton = cookieBanner.querySelector(".cookie-hide-button");
  if (hideButton) {
    hideButton.addEventListener("click", function(e) {
      e.preventDefault();
      cookieBanner.style.display = "none";
    });
  }
}
var hideButton;

// app/javascript/application.js
initAll();
moj.init();
/*! Bundled license information:

govuk-frontend/dist/govuk/components/accordion/accordion.mjs:
  (**
   * Accordion component
   *
   * This allows a collection of sections to be collapsed by default, showing only
   * their headers. Sections can be expanded or collapsed individually by clicking
   * their headers. A "Show all sections" button is also added to the top of the
   * accordion, which switches to "Hide all sections" when all the sections are
   * expanded.
   *
   * The state of each section is saved to the DOM via the `aria-expanded`
   * attribute, which also provides accessibility.
   *
   * @preserve
   * @augments ConfigurableComponent<AccordionConfig>
   *)

govuk-frontend/dist/govuk/components/button/button.mjs:
  (**
   * JavaScript enhancements for the Button component
   *
   * @preserve
   * @augments ConfigurableComponent<ButtonConfig>
   *)

govuk-frontend/dist/govuk/components/character-count/character-count.mjs:
  (**
   * Character count component
   *
   * Tracks the number of characters or words in the `.govuk-js-character-count`
   * `<textarea>` inside the element. Displays a message with the remaining number
   * of characters/words available, or the number of characters/words in excess.
   *
   * You can configure the message to only appear after a certain percentage
   * of the available characters/words has been entered.
   *
   * @preserve
   * @augments ConfigurableComponent<CharacterCountConfig>
   *)

govuk-frontend/dist/govuk/components/checkboxes/checkboxes.mjs:
  (**
   * Checkboxes component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/error-summary/error-summary.mjs:
  (**
   * Error summary component
   *
   * Takes focus on initialisation for accessible announcement, unless disabled in
   * configuration.
   *
   * @preserve
   * @augments ConfigurableComponent<ErrorSummaryConfig>
   *)

govuk-frontend/dist/govuk/components/exit-this-page/exit-this-page.mjs:
  (**
   * Exit this page component
   *
   * @preserve
   * @augments ConfigurableComponent<ExitThisPageConfig>
   *)

govuk-frontend/dist/govuk/components/file-upload/file-upload.mjs:
  (**
   * File upload component
   *
   * @preserve
   * @augments ConfigurableComponent<FileUploadConfig>
   *)

govuk-frontend/dist/govuk/components/header/header.mjs:
  (**
   * Header component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/notification-banner/notification-banner.mjs:
  (**
   * Notification Banner component
   *
   * @preserve
   * @augments ConfigurableComponent<NotificationBannerConfig>
   *)

govuk-frontend/dist/govuk/components/password-input/password-input.mjs:
  (**
   * Password input component
   *
   * @preserve
   * @augments ConfigurableComponent<PasswordInputConfig>
   *)

govuk-frontend/dist/govuk/components/radios/radios.mjs:
  (**
   * Radios component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/service-navigation/service-navigation.mjs:
  (**
   * Service Navigation component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/skip-link/skip-link.mjs:
  (**
   * Skip link component
   *
   * @preserve
   * @augments Component<HTMLAnchorElement>
   *)

govuk-frontend/dist/govuk/components/tabs/tabs.mjs:
  (**
   * Tabs component
   *
   * @preserve
   *)
*/
;
