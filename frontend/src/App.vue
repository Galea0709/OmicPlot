<template>
  <div class="page" :class="{ en: lang === 'en', 'is-home': activeNav === 'home' }">
    <header class="site-nav">
      <div class="site-nav__brand">
        <span class="site-nav__brand-icon" aria-hidden="true">
          <img class="site-nav__brand-icon-img" src="/icons/dna-logo.png" alt="" />
        </span>
        <span>OmicPlot</span>
      </div>
      <nav class="site-nav__menu" aria-label="Main">
        <button
          type="button"
          class="site-nav__item"
          :class="{ 'is-active': activeNav === 'home' }"
          @click="activeNav = 'home'"
        >
          {{ t.navHome }}
        </button>
        <button
          type="button"
          class="site-nav__item"
          :class="{ 'is-active': activeNav === 'analysis' }"
          @click="goToAnalysisHub"
        >
          {{ t.navAnalysis }}
        </button>
      </nav>
      <div class="site-nav__lang-wrap">
        <span class="site-nav__lang-divider" aria-hidden="true" />
        <div class="lang-slide site-nav__lang" role="tablist" :aria-label="t.langSwitchAria">
          <div class="lang-slide__track" :class="{ 'lang-slide__track--en': lang === 'en' }">
            <span class="lang-slide__thumb" aria-hidden="true" />
            <button
              type="button"
              role="tab"
              class="lang-slide__btn"
              :class="{ 'is-active': lang === 'zh' }"
              :aria-selected="lang === 'zh'"
              @click="lang = 'zh'"
            >
              中文
            </button>
            <button
              type="button"
              role="tab"
              class="lang-slide__btn"
              :class="{ 'is-active': lang === 'en' }"
              :aria-selected="lang === 'en'"
              @click="lang = 'en'"
            >
              EN
            </button>
          </div>
        </div>
      </div>
    </header>

    <div class="page-main">
    <section v-show="activeNav === 'home'" class="home-cover">
      <div class="home-cover__card">
        <h1 class="home-cover__title">OmicPlot</h1>
        <p class="home-cover__statement">{{ t.homeStatement }}</p>
        <div class="home-cover__actions">
          <el-button type="primary" class="home-cover__btn home-cover__btn--analysis" size="large" @click="goToAnalysisHub">
            {{ t.analyzeNow }}
          </el-button>
        </div>
      </div>
    </section>

    <div v-show="activeNav === 'analysis'" class="analysis-shell" :class="{ 'is-sidebar-collapsed': !analysisSidebarOpen }">
      <aside class="analysis-sidebar" aria-label="Analysis navigation">
        <div class="analysis-sidebar__head">
          <div class="analysis-sidebar__title-row">
            <button
              type="button"
              class="analysis-sidebar__title-text-btn"
              @click="onAnalysisSidebarTitleClick"
            >
              {{ t.analysisHubTitle }}
            </button>
            <button
              type="button"
              class="analysis-sidebar__chevron-btn"
              :class="{ 'is-open': analysisSidebarNavOpen }"
              :aria-expanded="analysisSidebarNavOpen"
              :aria-label="analysisSidebarNavOpen ? t.analysisSidebarNavCollapse : t.analysisSidebarNavExpand"
              :title="analysisSidebarNavOpen ? t.analysisSidebarNavCollapse : t.analysisSidebarNavExpand"
              @click.stop="toggleAnalysisSidebarNav"
            >
              <span class="analysis-sidebar__title-chevron" aria-hidden="true" />
            </button>
          </div>
        </div>
        <div v-show="analysisSidebarNavOpen" class="analysis-sidebar__body">
          <nav class="analysis-sidebar__nav">
            <button
              type="button"
              class="analysis-sidebar__item"
              :class="{ 'is-active': activeAnalysisTool === 'bubble' }"
              @click="openAnalysisTool('bubble')"
            >
              {{ t.analysisBubblePlot }}
            </button>
            <button
              type="button"
              class="analysis-sidebar__item"
              :class="{ 'is-active': activeAnalysisTool === 'bar' }"
              @click="openAnalysisTool('bar')"
            >
              {{ t.analysisBarChart }}
            </button>
          </nav>
          <p class="analysis-sidebar__note">{{ t.analysisSidebarDevNote }}</p>
        </div>
        <button
          type="button"
          class="analysis-sidebar-toggle"
          :aria-expanded="analysisSidebarOpen"
          :aria-label="analysisSidebarOpen ? t.analysisSidebarCollapse : t.analysisSidebarExpand"
          :title="analysisSidebarOpen ? t.analysisSidebarCollapse : t.analysisSidebarExpand"
          @click="toggleAnalysisSidebar"
        >
          <svg class="analysis-sidebar-toggle__icon" viewBox="0 0 24 24" aria-hidden="true">
            <path
              d="M15 6l-6 6 6 6"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </button>
      </aside>

      <div class="analysis-shell__main">
        <section v-if="!activeAnalysisTool" class="analysis-hub">
          <header class="analysis-hub__header">
            <h1 class="analysis-hub__title">{{ t.analysisHubTitle }}</h1>
            <div class="analysis-hub__divider" aria-hidden="true" />
          </header>
          <div class="analysis-hub__cards">
            <button type="button" class="analysis-hub__card" @click="openAnalysisTool('bubble')">
              <span class="analysis-hub__card-preview analysis-hub__card-preview--bubble" aria-hidden="true">
                <svg viewBox="0 0 320 200" xmlns="http://www.w3.org/2000/svg">
                  <rect width="320" height="200" fill="#f4f8fb" rx="8" />
                  <line x1="48" y1="24" x2="48" y2="168" stroke="#94a3b8" stroke-width="1.5" />
                  <line x1="48" y1="168" x2="292" y2="168" stroke="#94a3b8" stroke-width="1.5" />
                  <circle cx="118" cy="52" r="16" fill="#3b82f6" fill-opacity="0.75" />
                  <circle cx="168" cy="78" r="22" fill="#2563eb" fill-opacity="0.85" />
                  <circle cx="210" cy="108" r="12" fill="#60a5fa" fill-opacity="0.7" />
                  <circle cx="142" cy="118" r="18" fill="#1d4ed8" fill-opacity="0.8" />
                  <circle cx="228" cy="58" r="10" fill="#93c5fd" fill-opacity="0.75" />
                  <circle cx="252" cy="132" r="20" fill="#3b82f6" fill-opacity="0.82" />
                  <circle cx="96" cy="142" r="8" fill="#bfdbfe" fill-opacity="0.9" />
                </svg>
              </span>
              <span class="analysis-hub__card-label">{{ t.analysisBubblePlot }}</span>
            </button>
            <button type="button" class="analysis-hub__card" @click="openAnalysisTool('bar')">
              <span class="analysis-hub__card-preview analysis-hub__card-preview--bar" aria-hidden="true">
                <svg viewBox="0 0 320 200" xmlns="http://www.w3.org/2000/svg">
                  <rect width="320" height="200" fill="#f4f8fb" rx="8" />
                  <line x1="48" y1="24" x2="48" y2="168" stroke="#94a3b8" stroke-width="1.5" />
                  <line x1="48" y1="168" x2="292" y2="168" stroke="#94a3b8" stroke-width="1.5" />
                  <rect x="48" y="36" width="118" height="20" fill="#3b82f6" fill-opacity="0.75" rx="3" />
                  <rect x="48" y="64" width="178" height="20" fill="#2563eb" fill-opacity="0.85" rx="3" />
                  <rect x="48" y="92" width="208" height="20" fill="#1d4ed8" fill-opacity="0.8" rx="3" />
                  <rect x="48" y="120" width="132" height="20" fill="#60a5fa" fill-opacity="0.75" rx="3" />
                  <rect x="48" y="148" width="192" height="20" fill="#3b82f6" fill-opacity="0.82" rx="3" />
                </svg>
              </span>
              <span class="analysis-hub__card-label">{{ t.analysisBarChart }}</span>
            </button>
          </div>
        </section>

        <div v-else :key="activeAnalysisTool" class="analysis-view">
    <header class="top-bar">
      <div class="brand">
        <span class="name">{{ toolUi.toolName }}</span>
      </div>
      <p class="tagline">{{ toolUi.tagline }}</p>
    </header>

    <div class="mode-bar">
      <div class="mode-bar__inner">
        <span class="mode-bar__badge">{{ t.modeBarLabel }}</span>
        <div class="mode-slide" role="tablist" :aria-label="t.modeBarLabel">
          <div
            class="mode-slide__track"
            :class="{ 'mode-slide__track--go': activeTab === 'go' }"
          >
            <span class="mode-slide__thumb" aria-hidden="true" />
            <button
              type="button"
              role="tab"
              class="mode-slide__btn"
              :class="{ 'is-active': activeTab === 'kegg' }"
              :aria-selected="activeTab === 'kegg'"
              @click="activeTab = 'kegg'"
            >
              {{ t.tabKegg }}
            </button>
            <button
              type="button"
              role="tab"
              class="mode-slide__btn"
              :class="{ 'is-active': activeTab === 'go' }"
              :aria-selected="activeTab === 'go'"
              @click="activeTab = 'go'"
            >
              {{ t.tabGo }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="layout">
      <section class="col left">
        <el-card class="upload-card upload-card--dashed-wrap" shadow="never">
          <div
            class="file-drop-panel"
            :class="{ 'is-dragover': isDragOver }"
            role="region"
            :aria-label="t.degFile"
            @dragenter.prevent="onDragEnter"
            @dragleave.prevent="onDragLeave"
            @dragover.prevent="onDragOver"
            @drop.prevent="onFileDrop"
          >
            <input
              ref="fileInputRef"
              type="file"
              class="file-drop-panel__input"
              accept=".csv,.tsv,.txt,.rds,.xlsx,.xls"
              @change="onFileInputChange"
            />
            <div class="file-drop-panel__click-area">
              <h3 class="file-drop-panel__title">
                {{ t.degFile }}<span class="file-drop-panel__ext">{{ t.degFileFormats }}</span>
              </h3>
              <p class="muted file-drop-panel__hint">{{ t.degHint }}</p>
              <p class="file-drop-panel__drop-hint">{{ t.dropZoneTitle }}</p>
            </div>
            <div class="btn-row file-drop-panel__actions" @click.stop>
              <el-button class="soft" @click="openPreview">{{ t.formatPreview }}</el-button>
              <el-button
                v-if="toolExampleFiles.length === 1 && toolExampleFiles[0]?.file"
                class="soft"
                @click="loadExampleFile(toolExampleFiles[0].file)"
              >
                {{ t.example }}
              </el-button>
              <el-dropdown v-else-if="toolExampleFiles.length > 1" trigger="click" class="example-dropdown" @command="loadExampleFile">
                <el-button class="soft">
                  {{ t.example }}
                  <span class="example-caret" aria-hidden="true">▾</span>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item
                      v-for="(ex, exIdx) in toolExampleFiles"
                      :key="'ex-' + exIdx + '-' + String(ex.file || '')"
                      :command="String(ex.file || '')"
                    >
                      {{ exampleLabel(ex) }}
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
              <el-button type="primary" class="primary-blue" @click="triggerFileInput">
                {{ t.selectFile }}
              </el-button>
              <span class="file-status" :class="{ 'has-file': !!fileLabel }">
                {{ fileLabel ? `${t.selected}：${fileLabel}` : t.noFileSelected }}
              </span>
            </div>
          </div>
        </el-card>

        <div class="col-left-fill">
        <el-form label-position="top" class="param-form">
          <div class="param-form-section">
            <div class="param-form-section__head">
              <span class="param-form-section__icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path
                    d="M5 6h14"
                    stroke="currentColor"
                    stroke-width="1.75"
                    stroke-linecap="round"
                  />
                  <path
                    d="M5 6l5 10M19 6l-5 10"
                    stroke="currentColor"
                    stroke-width="1.75"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  />
                  <path
                    d="M10 16v5M14 16v5M10 21h4"
                    stroke="currentColor"
                    stroke-width="1.75"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  />
                </svg>
              </span>
              <span class="param-form-section__title">{{ t.paramGroupAnalysis }}</span>
            </div>
            <el-form-item :label="t.genome">
              <el-select v-model="form.genome" style="width: 100%">
                <el-option label="Mus musculus (mmu)" value="mmu" />
                <el-option label="Homo sapiens (hsa)" value="hsa" />
              </el-select>
            </el-form-item>

            <el-form-item :label="t.enrichType">
              <el-select v-model="form.enrichment_type" style="width: 100%">
                <template v-if="activeTab === 'kegg'">
                  <el-option label="KEGG" value="KEGG" />
                </template>
                <template v-else>
                  <el-option label="GO (ALL)" value="GO" />
                  <el-option label="GO BP" value="BP" />
                  <el-option label="GO CC" value="CC" />
                  <el-option label="GO MF" value="MF" />
                </template>
              </el-select>
            </el-form-item>

          </div>

          <div class="param-form-section param-form-section--divider">
            <div class="param-form-section__head">
              <span class="param-form-section__icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M4 19V5" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" />
                  <path d="M4 19h16" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" />
                  <path
                    d="M8 15v-4M12 15V9M16 15v-6"
                    stroke="currentColor"
                    stroke-width="1.5"
                    stroke-linecap="round"
                  />
                </svg>
              </span>
              <span class="param-form-section__title">{{ t.paramGroupDisplay }}</span>
            </div>
            <el-form-item :label="t.sigStandard">
              <el-select v-model="form.arrange_standard" style="width: 100%">
                <el-option :label="t.pvalue" value="pvalue" />
                <el-option :label="t.qvalue" value="qvalue" />
              </el-select>
            </el-form-item>

            <el-form-item :label="t.sortBy">
              <el-select v-model="form.arrange_way" style="width: 100%">
                <el-option
                  v-for="opt in sortByOptions"
                  :key="'s-' + opt.value"
                  :label="opt.label"
                  :value="opt.value"
                />
              </el-select>
            </el-form-item>
          </div>
        </el-form>

        <el-button
          class="run-main"
          type="primary"
          size="large"
          :loading="loading"
          @click="requestGenerateWithConfirm"
        >
          {{ toolUi.generate }}
        </el-button>
        <!-- 与右栏同高：增高落在本容器底部，不撑高表单内部 -->
        <div class="col-left-bottom-spacer" aria-hidden="true" />
        </div>
      </section>

      <section class="col right">
        <div class="col-right-panel">
        <el-card class="preview-card preview-card--inset" shadow="never">
          <template #header>
            <div class="preview-head">
              <div class="preview-head__title">
                <span>{{ t.preview }}</span>
                <el-tag
                  v-if="imageSrc && previewSourceLabel"
                  type="success"
                  effect="plain"
                  class="preview-head__source-tag"
                >
                  {{ previewSourceLabel }}
                </el-tag>
                <el-button
                  v-if="imageSrc"
                  type="primary"
                  link
                  class="preview-head__params-link"
                  @click="plotParamsJsonDialogVisible = true"
                >
                  {{ t.previewPlotParams }}
                </el-button>
              </div>
              <div class="preview-head__actions">
                <el-button
                  v-if="imageSrc"
                  type="primary"
                  link
                  class="preview-download"
                  @click="downloadPlotPng"
                >
                  {{ t.downloadPng }}
                </el-button>
                <el-tooltip
                  v-if="imageSrc"
                  placement="top"
                  :disabled="!!plotPdfObjectUrl"
                  :show-after="200"
                >
                  <template #content>
                    <span class="preview-pdf-tooltip">{{ pdfDownloadUnavailableHint }}</span>
                  </template>
                  <span class="preview-download-tooltip-trigger">
                    <el-button
                      type="primary"
                      link
                      class="preview-download"
                      :disabled="!plotPdfObjectUrl"
                      @click="downloadPlotPdf"
                    >
                      {{ t.downloadPdf }}
                    </el-button>
                  </span>
                </el-tooltip>
                <el-tag v-if="imageSrc" type="info" effect="plain">PNG</el-tag>
                <el-tag
                  v-if="imageSrc"
                  type="info"
                  effect="plain"
                  class="preview-format-tag"
                  :class="{ 'preview-format-tag--muted': !plotPdfObjectUrl }"
                >
                  PDF
                </el-tag>
              </div>
            </div>
          </template>
          <div class="preview-box" :class="{ 'preview-box--drawing': loading }">
            <div v-if="loading" class="preview-drawing-overlay" role="status" aria-live="polite">
              <div class="preview-drawing-spinner" aria-hidden="true" />
              <p class="preview-drawing-title">{{ toolUi.previewDrawingTitle }}</p>
              <div class="preview-drawing-bar" aria-hidden="true">
                <div class="preview-drawing-bar__fill" />
              </div>
              <p class="preview-drawing-hint">{{ toolUi.previewDrawingHint }}</p>
            </div>
            <div v-if="imageSrc" class="plot-img-host">
              <img :src="imageSrc" :alt="toolUi.plotImgAlt" class="plot-img" />
            </div>
            <div v-else class="preview-empty">
              <p class="empty-title">{{ t.noPlot }}</p>
              <p class="muted">{{ t.uploadFirst }}</p>
              <div class="tips">
                <p>{{ t.tip1 }}</p>
                <p>{{ t.tip2 }}</p>
              </div>
              <el-button class="run-example" size="large" @click="runExample">
                {{ t.runExample }}
              </el-button>
            </div>
          </div>
          <div v-if="imageSrc && statsDisplayRows.length" class="pathway-picker-bar">
            <span class="pathway-picker-bar__label">{{ t.pathwayPickerLabel }}</span>
            <el-select
              v-model="selectedPathwayDescription"
              filterable
              clearable
              class="pathway-picker-bar__select"
              :placeholder="toolUi.pathwayPickerPlaceholder"
            >
              <el-option
                v-for="(row, idx) in statsDisplayRows"
                :key="'pick-' + idx + '-' + String(row.Description ?? idx)"
                :label="String(row.Description ?? '')"
                :value="String(row.Description ?? '')"
              />
            </el-select>
            <el-button class="soft" @click="openSelectedPathwayDetail">
              {{ toolUi.pathwayPickerAction }}
            </el-button>
          </div>
          <p v-if="imageSrc && statsDisplayRows.length" class="preview-pathway-hint muted">
            {{ toolUi.previewPathwayHint }}
          </p>
          <p
            v-if="!isBarTool && imageSrc && statsDisplayRows.length"
            class="preview-pathway-highlight-note"
          >
            {{ t.pathwayHighlightOutsideNote }}
          </p>
        </el-card>

        <el-card class="style-card style-card--inset" shadow="never">
          <template #header>
            <div class="style-head style-head--with-subtabs">
              <div class="style-subtabs" role="tablist" :aria-label="t.styleCardTabsAria">
                <div
                  class="style-subtabs__track"
                  :class="{ 'style-subtabs__track--stats': styleSubTab === 'stats' }"
                >
                  <span class="style-subtabs__thumb" aria-hidden="true" />
                  <button
                    type="button"
                    role="tab"
                    class="style-subtabs__btn"
                    :class="{ 'is-active': styleSubTab === 'style' }"
                    :aria-selected="styleSubTab === 'style'"
                    @click="styleSubTab = 'style'"
                  >
                    {{ t.styleSection }}
                  </button>
                  <button
                    type="button"
                    role="tab"
                    class="style-subtabs__btn"
                    :class="{ 'is-active': styleSubTab === 'stats' }"
                    :aria-selected="styleSubTab === 'stats'"
                    @click="styleSubTab = 'stats'"
                  >
                    {{ t.statsTab }}
                  </button>
                </div>
              </div>
            </div>
          </template>

          <div v-show="styleSubTab === 'style'" class="style-tab-pane">
          <div
            class="style-param-block style-param-block--palette"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('palette') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('palette')"
              @click="toggleBubbleStyleSection('palette')"
              @keydown.enter.prevent="toggleBubbleStyleSection('palette')"
              @keydown.space.prevent="toggleBubbleStyleSection('palette')"
            >
              <span class="style-param-block__title">{{ isBarTool ? t.styleBlockPalette : t.styleBlockPaletteGrid }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('palette') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('palette')" class="style-param-block__body">
            <div class="style-top-block">
            <div class="style-row-4" :class="{ 'style-row-4--bar-palette': isBarTool }">
              <div class="field">
                <label>{{ t.colorLow }}</label>
                <div class="color-row">
                  <el-color-picker v-model="form.color_low" color-format="hex" />
                  <el-input v-model="form.color_low" />
                </div>
              </div>
              <div class="field">
                <label>{{ t.colorHigh }}</label>
                <div class="color-row">
                  <el-color-picker v-model="form.color_high" color-format="hex" />
                  <el-input v-model="form.color_high" />
                </div>
              </div>
              <div v-if="!isBarTool" class="field field--show-grid">
                <label>{{ t.showGrid }}</label>
                <el-switch
                  v-model="form.show_grid"
                  :active-text="t.showGridOn"
                  :inactive-text="t.showGridOff"
                />
              </div>
              <div v-if="!isBarTool" class="field field--grid-style-entry">
                <el-popover
                  v-model:visible="gridStyleExpanded"
                  placement="bottom-end"
                  :width="380"
                  trigger="click"
                  teleported
                  popper-class="grid-style-popover"
                >
                  <template #reference>
                    <div class="grid-style-entry-ref" role="button" tabindex="0">
                      <label>{{ t.gridLinesStyle }}</label>
                      <el-button
                        class="grid-style-expand-btn"
                        type="default"
                        plain
                        size="small"
                      >
                        {{ gridStyleExpanded ? t.gridLinesCollapse : t.gridLinesExpand }}
                        <span
                          class="grid-style-chevron"
                          :class="{ 'is-open': gridStyleExpanded }"
                          aria-hidden="true"
                        >▼</span>
                      </el-button>
                    </div>
                  </template>
                  <div
                    class="style-grid-style-panel style-grid-style-panel--popover"
                    role="group"
                    :aria-label="t.gridLinesStyle"
                  >
                    <div class="grid-style-section">
                      <p class="grid-style-tier-title">{{ t.gridLinesMajor }}</p>
                      <div class="grid-line-pair">
                        <div class="field field--grid-line-compact">
                          <label>{{ t.gridLineColor }}</label>
                          <div class="color-row color-row--grid-line-hex">
                            <el-color-picker
                              v-model="form.grid_major_color"
                              color-format="hex"
                              size="small"
                            />
                            <el-input v-model="form.grid_major_color" size="small" />
                          </div>
                        </div>
                        <div class="field field--grid-line-compact">
                          <label>{{ t.gridLineWidth }}</label>
                          <el-input-number
                            v-model="form.grid_major_linewidth"
                            class="grid-line-width-input"
                            size="small"
                            :min="0.05"
                            :max="2.5"
                            :step="0.05"
                          />
                        </div>
                      </div>
                    </div>
                    <div class="grid-style-section grid-style-section--minor">
                      <p class="grid-style-tier-title">{{ t.gridLinesMinor }}</p>
                      <div class="grid-line-pair">
                        <div class="field field--grid-line-compact">
                          <label>{{ t.gridLineColor }}</label>
                          <div class="color-row color-row--grid-line-hex">
                            <el-color-picker
                              v-model="form.grid_minor_color"
                              color-format="hex"
                              size="small"
                            />
                            <el-input v-model="form.grid_minor_color" size="small" />
                          </div>
                        </div>
                        <div class="field field--grid-line-compact">
                          <label>{{ t.gridLineWidth }}</label>
                          <el-input-number
                            v-model="form.grid_minor_linewidth"
                            class="grid-line-width-input"
                            size="small"
                            :min="0.05"
                            :max="2.5"
                            :step="0.05"
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                </el-popover>
              </div>
            </div>
            </div>
            </div>
          </div>

          <!-- 基础参数（默认展开，含 TopN / 横坐标） -->
          <div
            class="style-param-block style-param-block--basic"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('basic') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('basic')"
              @click="toggleBubbleStyleSection('basic')"
              @keydown.enter.prevent="toggleBubbleStyleSection('basic')"
              @keydown.space.prevent="toggleBubbleStyleSection('basic')"
            >
              <span class="style-param-block__title">{{ t.styleBlockBasic }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('basic') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('basic')" class="style-param-block__body">
            <div
              class="style-grid style-grid--basic-params"
              :class="{ 'style-grid--basic-params--bar': isBarTool }"
            >
            <div class="field">
              <label>{{ t.plotTitle }}</label>
              <el-input v-model="form.plot_title" size="small" />
            </div>
            <div class="field">
              <label>{{ t.xTitle }}</label>
              <el-input v-model="form.x_axis_title" size="small" />
            </div>
            <div class="field">
              <label>{{ t.yTitle }}</label>
              <el-input v-model="form.y_axis_title" size="small" />
            </div>
            <div class="field">
              <label>{{ t.topN }}</label>
              <el-select
                v-model="topPathwaysSelect"
                class="param-topn-select"
                filterable
                allow-create
                default-first-option
                size="small"
                :placeholder="t.topNPlaceholder"
                style="width: 100%"
              >
                <el-option :value="10" label="10" />
                <el-option :value="20" label="20" />
                <el-option :value="30" label="30" />
              </el-select>
            </div>
            <div class="field">
              <label>{{ t.xAxis }}</label>
              <el-select v-model="form.x_axis" size="small" style="width: 100%">
                <el-option
                  v-for="opt in xAxisOptions"
                  :key="'style-x-' + opt.value"
                  :label="opt.label"
                  :value="opt.value"
                />
              </el-select>
            </div>
            <div v-if="isBarTool" class="field field--bar-show-gene-id">
              <label>{{ t.barShowGeneId }}</label>
              <el-switch
                v-model="form.bar_show_gene_id"
                :active-text="t.showGridOn"
                :inactive-text="t.showGridOff"
              />
            </div>
            </div>
            <div
              v-if="isBarTool && form.bar_show_gene_id"
              class="style-grid style-grid--basic-params style-grid--basic-params--bar-gene"
            >
              <div class="field">
                <label>{{ t.barGeneShowN }}</label>
                <el-input-number v-model="form.bar_gene_show_n" :min="1" :max="200" :step="1" />
              </div>
              <div class="field">
                <label>{{ t.barGeneTextX }}</label>
                <el-input-number v-model="form.bar_gene_text_x" :step="0.001" />
              </div>
              <div class="field">
                <label>{{ t.barGeneTextVjust }}</label>
                <el-input-number v-model="form.bar_gene_text_vjust" :min="-10" :max="10" :step="0.1" />
              </div>
              <div class="field">
                <label>{{ t.barGeneTextSize }}</label>
                <el-input-number v-model="form.bar_gene_text_size" :min="1" :max="20" :step="0.1" />
              </div>
            </div>
            </div>
          </div>

          <div
            class="style-param-block"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('typography') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('typography')"
              @click="toggleBubbleStyleSection('typography')"
              @keydown.enter.prevent="toggleBubbleStyleSection('typography')"
              @keydown.space.prevent="toggleBubbleStyleSection('typography')"
            >
              <span class="style-param-block__title">{{ t.styleBlockTypography }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('typography') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('typography')" class="style-param-block__body">
            <div class="style-grid style-grid--numeric-params style-grid--params-4col">
            <div class="field">
              <label>{{ t.plotTitleStyle }}</label>
              <el-input-number v-model="form.title_size" :min="6" :max="32" />
            </div>
            <div class="field">
              <label>{{ t.axisXTitleStyle }}</label>
              <el-input-number v-model="form.axis_x_title_size" :min="6" :max="28" />
            </div>
            <div class="field">
              <label>{{ t.axisYTitleStyle }}</label>
              <el-input-number v-model="form.axis_y_title_size" :min="6" :max="28" />
            </div>
            <div v-if="!isBarTool" class="field">
              <label>{{ t.axisXTickStyle }}</label>
              <el-input-number v-model="form.axis_x_text_size" :min="6" :max="24" />
            </div>
            <div v-if="!isBarTool" class="field">
              <label>{{ t.axisYTickStyle }}</label>
              <el-input-number v-model="form.axis_y_text_size" :min="6" :max="24" />
            </div>
            <div v-if="!isBarTool" class="field">
              <label>{{ t.pathwayWrapWidth }}</label>
              <el-input-number v-model="form.y_wrap_width" :min="10" :max="200" :step="1" />
            </div>
            <div v-if="!isBarTool" class="field">
              <label>{{ t.axisYLineheightLabel }}</label>
              <el-input-number v-model="form.axis_y_text_lineheight" :min="0.75" :max="2.2" :step="0.05" />
            </div>
            <div v-if="isBarTool" class="field">
              <label>{{ t.axisXTickStyle }}</label>
              <el-input-number v-model="form.axis_x_text_size" :min="6" :max="24" />
            </div>
            <div v-if="isBarTool" class="field">
              <label>{{ t.barPathwayTextSize }}</label>
              <el-input-number v-model="form.bar_pathway_text_size" :min="1" :max="20" :step="0.1" />
            </div>
            <div class="field field--axis-bold-entry">
              <el-popover
                v-model:visible="axisBoldSettingsExpanded"
                placement="bottom-start"
                :width="320"
                trigger="click"
                teleported
                popper-class="axis-bold-popover"
              >
                <template #reference>
                  <div class="axis-bold-entry-ref" role="button" tabindex="0">
                    <label>{{ t.axisBoldMenuTitle }}</label>
                    <el-button
                      class="grid-style-expand-btn"
                      type="default"
                      plain
                      size="small"
                    >
                      {{ axisBoldSettingsExpanded ? t.gridLinesCollapse : t.axisBoldMenuOpen }}
                      <span
                        class="grid-style-chevron"
                        :class="{ 'is-open': axisBoldSettingsExpanded }"
                        aria-hidden="true"
                      >▼</span>
                    </el-button>
                  </div>
                </template>
                <div
                  class="axis-bold-popover-panel"
                  role="group"
                  :aria-label="t.axisBoldMenuTitle"
                >
                  <div class="axis-bold-popover-row">
                    <span class="axis-bold-popover-row__label">{{ t.axisBoldBitMain }}</span>
                    <el-switch
                      v-model="form.plot_title_bold"
                      :active-text="t.axisBoldOn"
                      :inactive-text="t.axisBoldOff"
                    />
                  </div>
                  <div class="axis-bold-popover-row">
                    <span class="axis-bold-popover-row__label">{{ t.axisBoldBitXTitle }}</span>
                    <el-switch
                      v-model="form.axis_x_title_bold"
                      :active-text="t.axisBoldOn"
                      :inactive-text="t.axisBoldOff"
                    />
                  </div>
                  <div class="axis-bold-popover-row">
                    <span class="axis-bold-popover-row__label">{{ t.axisBoldBitYTitle }}</span>
                    <el-switch
                      v-model="form.axis_y_title_bold"
                      :active-text="t.axisBoldOn"
                      :inactive-text="t.axisBoldOff"
                    />
                  </div>
                  <div class="axis-bold-popover-row">
                    <span class="axis-bold-popover-row__label">{{ t.axisBoldBitXTick }}</span>
                    <el-switch
                      v-model="form.axis_x_text_bold"
                      :active-text="t.axisBoldOn"
                      :inactive-text="t.axisBoldOff"
                    />
                  </div>
                  <div v-if="!isBarTool" class="axis-bold-popover-row">
                    <span class="axis-bold-popover-row__label">{{ t.axisBoldBitYTick }}</span>
                    <el-switch
                      v-model="form.axis_y_text_bold"
                      :active-text="t.axisBoldOn"
                      :inactive-text="t.axisBoldOff"
                    />
                  </div>
                  <div v-if="isBarTool" class="axis-bold-popover-row">
                    <span class="axis-bold-popover-row__label">{{ t.barPathwayTextBold }}</span>
                    <el-switch
                      v-model="form.bar_pathway_text_bold"
                      :active-text="t.axisBoldOn"
                      :inactive-text="t.axisBoldOff"
                    />
                  </div>
                </div>
              </el-popover>
            </div>
            </div>
            </div>
          </div>

          <div
            v-if="!isBarTool"
            class="style-param-block style-param-block--bubble-size"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('bubble') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('bubble')"
              @click="toggleBubbleStyleSection('bubble')"
              @keydown.enter.prevent="toggleBubbleStyleSection('bubble')"
              @keydown.space.prevent="toggleBubbleStyleSection('bubble')"
            >
              <span class="style-param-block__title">{{ t.styleBlockBubble }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('bubble') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('bubble')" class="style-param-block__body">
            <div class="style-grid style-grid--numeric-params style-grid--bubble-size-row">
            <div class="field">
              <label>{{ t.bubbleMin }}</label>
              <el-input-number v-model="form.bubble_size_min" :min="0.5" :max="20" :step="0.5" />
            </div>
            <div class="field">
              <label>{{ t.bubbleMax }}</label>
              <el-input-number v-model="form.bubble_size_max" :min="1" :max="30" :step="0.5" />
            </div>
            <div class="field field--bubble-breaks">
              <label>{{ t.bubbleBreaks }}</label>
              <div class="field-bubble-breaks__control-row">
                <el-input
                  v-model="form.bubble_breaks_custom"
                  size="small"
                  :placeholder="t.bubbleBreaksPh"
                />
                <el-popover
                  placement="bottom-start"
                  :width="420"
                  trigger="click"
                  teleported
                  popper-class="bubble-breaks-help-popper"
                >
                  <template #reference>
                    <button
                      type="button"
                      class="bubble-breaks-help-chip"
                      :aria-label="t.bubbleBreaksHelpAria"
                    >
                      <svg
                        class="bubble-breaks-help-chip__icon"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                        focusable="false"
                      >
                        <path
                          fill="currentColor"
                          d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"
                        />
                      </svg>
                      <span class="bubble-breaks-help-chip__text">{{ t.bubbleBreaksHelpChip }}</span>
                    </button>
                  </template>
                  <div class="bubble-breaks-help" role="document">
                    <p class="bubble-breaks-help__title">{{ t.bubbleBreaksHelpTitle }}</p>
                    <p class="bubble-breaks-help__sub">{{ t.bubbleBreaksHelpAutoHead }}</p>
                    <p class="bubble-breaks-help__body">{{ t.bubbleBreaksHelpAutoBody }}</p>
                    <p class="bubble-breaks-help__sub">{{ t.bubbleBreaksHelpManualHead }}</p>
                    <p class="bubble-breaks-help__body">{{ t.bubbleBreaksHelpManualBody }}</p>
                    <p class="bubble-breaks-help__sub">{{ t.bubbleBreaksHelpFormatHead }}</p>
                    <p class="bubble-breaks-help__body">{{ t.bubbleBreaksHelpFormatBody }}</p>
                    <p class="bubble-breaks-help__note">{{ t.bubbleBreaksHelpNote }}</p>
                  </div>
                </el-popover>
              </div>
            </div>
            </div>
            </div>
          </div>

          <div
            v-if="isBarTool"
            class="style-param-block style-param-block--bar-style"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('bar') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('bar')"
              @click="toggleBubbleStyleSection('bar')"
              @keydown.enter.prevent="toggleBubbleStyleSection('bar')"
              @keydown.space.prevent="toggleBubbleStyleSection('bar')"
            >
              <span class="style-param-block__title">{{ t.styleBlockBar }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('bar') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('bar')" class="style-param-block__body">
            <div class="style-grid style-grid--numeric-params style-grid--params-4col">
              <div class="field">
                <label>{{ t.barWidth }}</label>
                <el-input-number v-model="form.bar_width" :min="0.05" :max="1" :step="0.05" />
              </div>
              <div class="field">
                <label>{{ t.barAlpha }}</label>
                <el-input-number v-model="form.bar_alpha" :min="0.05" :max="1" :step="0.05" />
              </div>
              <div class="field">
                <label>{{ t.barXExpandLeft }}</label>
                <el-input-number v-model="form.bar_x_expand_left" :min="0" :max="2" :step="0.01" />
              </div>
              <div class="field">
                <label>{{ t.barXExpandRight }}</label>
                <el-input-number v-model="form.bar_x_expand_right" :min="0" :max="2" :step="0.01" />
              </div>
              <div class="field">
                <label>{{ t.barYTicks }}</label>
                <el-switch
                  v-model="form.bar_y_ticks"
                  :active-text="t.showGridOn"
                  :inactive-text="t.showGridOff"
                />
              </div>
              <div class="field">
                <label>{{ t.barYTickLengthCm }}</label>
                <el-input-number v-model="form.bar_y_tick_length_cm" :min="0" :max="2" :step="0.1" />
              </div>
              <div class="field">
                <label>{{ t.barPathwayTextX }}</label>
                <el-input-number v-model="form.bar_pathway_text_x" :step="0.001" />
              </div>
            </div>
            </div>
          </div>

          <div
            class="style-param-block style-param-block--legend"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('legend') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('legend')"
              @click="toggleBubbleStyleSection('legend')"
              @keydown.enter.prevent="toggleBubbleStyleSection('legend')"
              @keydown.space.prevent="toggleBubbleStyleSection('legend')"
            >
              <span class="style-param-block__title">{{ t.styleBlockLegend }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('legend') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('legend')" class="style-param-block__body">
            <div class="style-grid--legend-compact-one-row" :class="{ 'style-grid--legend-bar': isBarTool }">
                <div class="field field--legend-tight field--legend-color-title">
                  <label :title="t.legendColorTitleLabel">{{ t.legendCompactColorTitle }}</label>
                  <el-input
                    v-model="form.legend_color_title"
                    size="small"
                    clearable
                    :placeholder="legendColorTitlePlaceholder"
                    :title="t.legendColorTitlePlaceholder"
                  />
                </div>
                <div class="field field--legend-tight field--legend-num">
                  <label :title="t.legendColorTitleSizeLabel">{{ t.legendCompactColorSize }}</label>
                  <el-input-number
                    v-model="form.legend_color_title_size"
                    size="small"
                    :min="6"
                    :max="28"
                    :step="1"
                  />
                </div>
                <div v-if="!isBarTool" class="field field--legend-tight field--legend-count-title">
                  <label :title="t.legendSizeTitleLabel">{{ t.legendCompactCountTitle }}</label>
                  <el-input
                    v-model="form.legend_size_title"
                    size="small"
                    clearable
                    :placeholder="t.legendCompactCountTitlePh"
                  />
                </div>
                <div v-if="!isBarTool" class="field field--legend-tight field--legend-num">
                  <label :title="t.legendSizeTitleSizeLabel">{{ t.legendCompactCountSize }}</label>
                  <el-input-number
                    v-model="form.legend_size_title_size"
                    size="small"
                    :min="6"
                    :max="28"
                    :step="1"
                  />
                </div>
                <div class="field field--legend-tight field--legend-num field--legend-barwidth">
                  <label :title="t.paramColorbarBarwidthMm">{{ t.legendCompactBarwidth }}</label>
                  <el-input-number
                    v-model="form.colorbar_barwidth_mm"
                    size="small"
                    :min="1.2"
                    :max="8"
                    :step="0.1"
                  />
                </div>
                <div class="field field--legend-tight field--legend-position">
                  <label :title="t.paramLegendPosition">{{ t.legendCompactPosition }}</label>
                  <el-select v-model="form.legend_position" size="small" class="legend-compact-select">
                    <el-option :label="t.legendPosRight" value="right" />
                    <el-option :label="t.legendPosLeft" value="left" />
                    <el-option :label="t.legendPosBottom" value="bottom" />
                    <el-option :label="t.legendPosTop" value="top" />
                  </el-select>
                </div>
            </div>
            </div>
          </div>

          <div
            class="style-param-block"
            :class="{ 'style-param-block--folded': !isBubbleStyleSectionOpen('canvas') }"
          >
            <div
              class="style-param-block__head style-param-block__head--collapsible"
              role="button"
              tabindex="0"
              :aria-expanded="isBubbleStyleSectionOpen('canvas')"
              @click="toggleBubbleStyleSection('canvas')"
              @keydown.enter.prevent="toggleBubbleStyleSection('canvas')"
              @keydown.space.prevent="toggleBubbleStyleSection('canvas')"
            >
              <span class="style-param-block__title">{{ t.styleBlockCanvas }}</span>
              <span
                class="style-param-block__chevron"
                :class="{ 'is-open': isBubbleStyleSectionOpen('canvas') }"
                aria-hidden="true"
              >▼</span>
              <span class="style-param-block__line" aria-hidden="true" />
            </div>
            <div v-show="isBubbleStyleSectionOpen('canvas')" class="style-param-block__body">
            <div class="style-grid style-grid--canvas-params">
            <div class="field">
              <label>{{ t.plotW }}</label>
              <el-input-number v-model="form.plot_width_cm" :min="0" :max="80" :step="0.5" />
            </div>
            <div class="field">
              <label>{{ t.plotH }}</label>
              <el-input-number v-model="form.plot_height_cm" :min="0" :max="80" :step="0.5" />
            </div>
            <div class="field">
              <label>{{ t.dpi }}</label>
              <el-input-number v-model="form.dpi" :min="72" :max="600" />
            </div>
            </div>
            </div>
          </div>

          </div>

          <div v-show="styleSubTab === 'stats'" class="style-tab-pane style-stats-page">
            <template v-if="statsDisplayRows.length">
              <div class="style-stats-kpis" role="presentation">
                <div v-for="(lbl, idx) in statsKpiLabels" :key="idx" class="style-stats-kpi">
                  <span class="style-stats-kpi__label">{{ lbl }}</span>
                  <span class="style-stats-kpi__value">{{ statsKpiNumbers[idx] }}</span>
                </div>
              </div>
              <p v-if="statsMeta" class="style-stats-param-line muted">
                genome={{ statsMeta.genome }} · {{ statsMeta.enrichment_type }} · TopN={{ statsMeta.top_pathways }} ·
                {{ statsMeta.arrange_standard }} / {{ statsMeta.arrange_way }} · X={{ statsMeta.x_axis }}
              </p>

              <div class="style-stats-download-block">
                <div>
                  <div class="style-stats-download-title">{{ t.statsRawCap }}</div>
                  <p class="muted style-stats-download-desc">{{ t.statsRawHint }}</p>
                </div>
                <el-button type="primary" plain @click="downloadStatsRawCsv">{{ t.statsDlRaw }}</el-button>
              </div>

              <div class="style-stats-sorted-head">
                <div>
                  <div class="style-stats-download-title">{{ t.statsSortedCap }}</div>
                  <p class="muted style-stats-download-desc">{{ t.statsSortedHint }}</p>
                </div>
                <el-button type="primary" @click="downloadStatsSortedCsv">{{ t.statsDlSorted }}</el-button>
              </div>

              <div class="style-stats-table-toolbar">
                <span class="style-stats-rows-total">{{ statsRowsTotalLabel }}</span>
                <div class="style-stats-page-controls">
                  <span class="muted">{{ t.statsPageShow }}</span>
                  <el-select v-model="statsPageMode" size="small" class="style-stats-page-select">
                    <el-option v-for="n in statsPageSizeOptions" :key="n" :label="String(n)" :value="String(n)" />
                    <el-option :label="t.statsPageCustom" value="custom" />
                  </el-select>
                  <el-input-number
                    v-if="statsPageMode === 'custom'"
                    v-model="statsCustomPageSize"
                    size="small"
                    :min="1"
                    :max="500"
                    class="style-stats-page-custom"
                  />
                </div>
              </div>

              <el-table
                class="style-stats-el-table"
                :data="statsPagedRows"
                border
                stripe
                size="small"
                max-height="460"
                @sort-change="onStatsSortChange"
              >
                <el-table-column
                  v-for="col in statsTableColumnKeys"
                  :key="'stc-' + col"
                  :prop="col"
                  :label="col"
                  sortable="custom"
                  min-width="120"
                  show-overflow-tooltip
                />
              </el-table>

              <div class="style-stats-pagination">
                <el-pagination
                  background
                  layout="total, prev, pager, next"
                  :total="statsRowsSorted.length"
                  :page-size="statsUiPageSizeNum"
                  :current-page="statsCurrentPage"
                  @current-change="setStatsCurrentPage"
                />
              </div>
            </template>
            <template v-else>
              <div class="style-stats-intro">
                <p class="style-stats-intro__title">{{ t.statsComingTitle }}</p>
                <p class="style-stats-intro__hint">{{ toolUi.statsComingHint }}</p>
              </div>
              <div class="style-stats-kpis" role="presentation">
                <div v-for="(lbl, idx) in statsKpiLabels" :key="'ph-' + idx" class="style-stats-kpi">
                  <span class="style-stats-kpi__label">{{ lbl }}</span>
                  <span class="style-stats-kpi__value">—</span>
                </div>
              </div>
            </template>
          </div>
        </el-card>
        </div>
      </section>
    </div>

    <el-dialog v-model="previewVisible" class="platform-dialog format-preview-dialog" :title="t.formatPreview" width="min(860px, 94vw)">
      <p v-if="previewLoading" class="format-preview-message muted">{{ t.formatPreviewLoading }}</p>
      <p v-else-if="previewPlainText" class="format-preview-message">{{ previewPlainText }}</p>
      <template v-else-if="previewTableRows.length">
        <p v-if="previewTruncatedNote" class="format-preview-note muted">{{ previewTruncatedNote }}</p>
        <div class="format-preview-table-wrap">
          <el-table
            class="format-preview-table"
            :data="previewTableRows"
            border
            stripe
            size="small"
            max-height="420"
          >
            <el-table-column
              v-for="col in previewTableColumns"
              :key="'fp-' + col"
              :prop="col"
              :label="col"
              min-width="100"
              show-overflow-tooltip
            />
          </el-table>
        </div>
      </template>
    </el-dialog>

    <el-dialog
      v-model="plotParamsJsonDialogVisible"
      class="platform-dialog plot-params-read-dialog"
      width="min(640px, 94vw)"
      :title="t.previewPlotParamsTitle"
      destroy-on-close
    >
      <p class="muted plot-params-read-hint">{{ t.previewPlotParamsHint }}</p>
      <p v-if="!lastPlotParamsDisplayRows.length" class="muted plot-params-read-empty">{{ t.previewPlotParamsEmpty }}</p>
      <div v-else class="plot-confirm-params-scroll">
        <dl class="plot-confirm-dl plot-params-read-dl">
          <template v-for="(item, idx) in lastPlotParamsDisplayRows" :key="'pp-' + idx + '-' + item.key">
            <dt>{{ item.key }}</dt>
            <dd>{{ item.value }}</dd>
          </template>
        </dl>
      </div>
      <template #footer>
        <el-button type="primary" @click="plotParamsJsonDialogVisible = false">{{ t.previewPlotParamsClose }}</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="plotConfirmVisible"
      class="platform-dialog plot-confirm-dialog"
      width="min(640px, 92vw)"
      :title="t.plotConfirmTitle"
      draggable
      destroy-on-close
    >
      <p class="muted plot-confirm-hint">{{ t.plotConfirmHint }}</p>
      <p v-if="plotConfirmChangedItems.length" class="plot-confirm-changes-intro">
        {{ t.plotConfirmChangesIntro }}
      </p>
      <ul v-if="plotConfirmChangedItems.length" class="plot-confirm-changes-list">
        <li v-for="item in plotConfirmChangedItems" :key="'pcc-' + item.id">
          <span class="plot-confirm-changes-label">{{ item.key }}：</span>
          <span class="plot-confirm-changes-diff">
            <span class="plot-confirm-old">{{ item.oldValue }}</span>
            <span class="plot-confirm-arrow" aria-hidden="true">→</span>
            <span class="plot-confirm-new">{{ item.value }}</span>
          </span>
        </li>
      </ul>
      <div class="plot-confirm-params-scroll">
        <dl class="plot-confirm-dl">
          <template v-for="item in plotConfirmItemsWithDiff" :key="'pci-' + item.id">
            <dt :class="{ 'plot-confirm-dt--changed': item.changed }">{{ item.key }}</dt>
            <dd :class="{ 'plot-confirm-dd--changed': item.changed }">
              <template v-if="item.changed">
                <span class="plot-confirm-old">{{ item.oldValue }}</span>
                <span class="plot-confirm-arrow" aria-hidden="true">→</span>
                <span class="plot-confirm-new">{{ item.value }}</span>
              </template>
              <template v-else>{{ item.value }}</template>
            </dd>
          </template>
        </dl>
      </div>
      <template #footer>
        <div class="plot-confirm-footer">
          <el-button @click="plotConfirmVisible = false">{{ t.plotConfirmCancel }}</el-button>
          <el-button type="primary" :loading="loading" @click="confirmPlotAction">
            {{ t.plotConfirmActionGenerate }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog
      v-model="pathwayDetailVisible"
      class="platform-dialog pathway-detail-dialog"
      width="min(720px, 92vw)"
      :title="pathwayDetailTitle"
      destroy-on-close
    >
      <p class="muted pathway-detail-hint">{{ pathwayDetailHintText }}</p>
      <div
        v-if="isBarTool && pathwayDetailCurrentDescription"
        class="pathway-gene-custom-panel"
      >
        <div class="pathway-gene-custom-panel__title">{{ t.pathwayGeneCustomTitle }}</div>
        <p class="muted pathway-gene-custom-panel__hint">{{ t.pathwayGeneCustomHint }}</p>
        <div v-if="!pathwayGeneCustomActive" class="pathway-gene-auto-block">
          <div class="pathway-gene-auto-block__label">{{ t.pathwayGeneAutoLabel }}</div>
          <div class="pathway-gene-auto-block__value">{{ pathwayAutoGeneIdsText }}</div>
          <p class="muted pathway-gene-auto-block__note">{{ t.pathwayGeneAutoNote }}</p>
        </div>
        <div v-else class="pathway-gene-custom-active-block">
          <div class="pathway-gene-custom-active-block__label">{{ t.pathwayGeneCustomActiveLabel }}</div>
          <div class="pathway-gene-custom-active-block__value">{{ pathwayGeneCustomDisplayText }}</div>
        </div>
        <label class="pathway-gene-custom-panel__input-label">{{ t.pathwayGeneCustomInputLabel }}</label>
        <el-input
          v-model="pathwayGeneCustomDraft"
          type="textarea"
          :rows="4"
          :placeholder="t.pathwayGeneCustomInputPlaceholder"
        />
        <div class="pathway-gene-custom-panel__actions">
          <el-button type="primary" @click="applyPathwayGeneCustom">
            {{ t.pathwayGeneCustomApply }}
          </el-button>
          <el-button :disabled="!pathwayGeneCustomActive && !pathwayGeneCustomDraft.trim()" @click="clearPathwayGeneCustom">
            {{ t.pathwayGeneCustomClear }}
          </el-button>
        </div>
        <p class="muted pathway-gene-custom-panel__foot">{{ t.pathwayGeneCustomFoot }}</p>
      </div>
      <div
        v-if="!isBarTool && pathwayDetailCurrentDescription"
        class="pathway-highlight-panel"
      >
        <div class="pathway-highlight-panel__head">
          <span class="pathway-highlight-panel__title">{{ t.pathwayHighlightPanelTitle }}</span>
          <el-switch
            v-model="pathwayHighlightDraft"
            :active-text="t.pathwayHighlightOn"
            :inactive-text="t.pathwayHighlightOff"
            @change="onPathwayHighlightToggle"
          />
        </div>
        <p class="muted pathway-highlight-panel__hint">
          {{ t.pathwayHighlightPanelHint }}
        </p>
      </div>
      <dl class="pathway-detail-dl">
        <template v-for="entry in pathwayDetailEntriesDisplay" :key="'pd-' + entry.key">
          <dt>{{ entry.key === "geneID" ? t.pathwayGeneIdFieldLabel : entry.key }}</dt>
          <dd>{{ entry.value }}</dd>
        </template>
      </dl>
    </el-dialog>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import {
  computed,
  nextTick,
  onMounted,
  onUnmounted,
  reactive,
  ref,
  toRaw,
  watch
} from "vue";
import { ElMessage } from "element-plus";
import { requestBubblePlot } from "./api";

const lang = ref("zh");
const activeTab = ref("kegg");
const activeNav = ref("home");
/** 分析区：null 为入口 hub；bubble 气泡图；bar 条形图 */
const activeAnalysisTool = ref(null);

const isBarTool = computed(() => activeAnalysisTool.value === "bar");

/** 分析区左侧导航：展开 / 收起 */
const analysisSidebarOpen = ref(true);
/** 侧栏「富集分析」下子菜单（气泡图 / 条形图）是否展开；默认展开，仅点击箭头可收起 */
const analysisSidebarNavOpen = ref(true);

function toggleAnalysisSidebar() {
  analysisSidebarOpen.value = !analysisSidebarOpen.value;
}

function goToAnalysisHub() {
  syncActiveToolStateToStore();
  activeNav.value = "analysis";
  activeAnalysisTool.value = null;
}

/** 点击侧栏「富集分析」文字：回到入口卡片页 */
function onAnalysisSidebarTitleClick() {
  if (!analysisSidebarOpen.value) {
    analysisSidebarOpen.value = true;
  }
  goToAnalysisHub();
}

/** 点击侧栏箭头：展开 / 收起气泡图、条形图子菜单 */
function toggleAnalysisSidebarNav() {
  if (!analysisSidebarOpen.value) {
    analysisSidebarOpen.value = true;
  }
  analysisSidebarNavOpen.value = !analysisSidebarNavOpen.value;
}

/** 右侧样式卡片：样式与参数 | 统计结果 */
const styleSubTab = ref("style");
/** 样式卡片第一行：网格线颜色/线宽折叠面板 */
const gridStyleExpanded = ref(false);
/** 右侧「样式与参数」各区块折叠状态（气泡图 / 条形图共用） */
function createDefaultBubbleStyleSections() {
  return {
    palette: true,
    basic: true,
    typography: false,
    bubble: false,
    bar: false,
    legend: false,
    canvas: false
  };
}
const bubbleStyleSections = reactive(createDefaultBubbleStyleSections());

function isBubbleStyleSectionOpen(key) {
  return !!bubbleStyleSections[key];
}

function toggleBubbleStyleSection(key) {
  bubbleStyleSections[key] = !bubbleStyleSections[key];
}
/** 「字号与字形」：各部位加粗合并为弹层内分别设置 */
const axisBoldSettingsExpanded = ref(false);
const previewVisible = ref(false);
const previewLoading = ref(false);
const previewPlainText = ref("");
const previewTableColumns = ref([]);
const previewTableRows = ref([]);
const previewTruncatedNote = ref("");
const loading = ref(false);
const imageSrc = ref("");
/** 气泡图用 Blob URL，避免超长 data:base64 超出浏览器限制导致裂图 */
const plotObjectUrl = ref(null);
/** 与当前预览同一次分析生成的 PDF，供「下载 PDF」直接落盘（不再次请求后端） */
const plotPdfObjectUrl = ref(null);
const fileLabel = ref("");
const rawFile = ref(null);
const fileInputRef = ref(null);
const isDragOver = ref(false);
const dragDepth = ref(0);

/** 统计结果：全量富集表（CSV 文本）与按当前作图参数排序后的展示表 */
const statsRawCsv = ref("");
const statsDisplayCsv = ref("");
const statsDisplayRows = ref([]);
/** 与 clusterProfiler 一致的全量富集行（JSON），用于按 Description 匹配完整字段 */
const statsRawRows = ref([]);
const statsMeta = ref(null);
const statsPageMode = ref("10");
const statsCustomPageSize = ref(10);
const statsUiPageSize = ref(10);
const statsCurrentPage = ref(1);
const statsSortProp = ref("");
const statsSortOrder = ref("");
const statsPageSizeOptions = [5, 10, 20, 25, 30];

const pathwayDetailVisible = ref(false);
const pathwayDetailTitle = ref("");
const pathwayDetailEntries = ref([]);
const pathwayDetailIsFull = ref(false);
const pathwayDetailCurrentDescription = ref("");
/** 条形图：按通路 Description 自定义图上展示的基因 ID（非空则覆盖自动 TopN） */
const barPathwayCustomGeneIds = ref({});
const pathwayGeneCustomDraft = ref("");
const highlightedPathways = ref([]);
const pathwayHighlightDraft = ref(false);
const selectedPathwayDescription = ref("");
const plotConfirmVisible = ref(false);
/** 打开确认弹窗或表单变更时递增，避免 computed 因 toRaw 未追踪到第二次及以后的改参 */
const plotConfirmOpenSeq = ref(0);
/** 预览区：查看与当前图对应的请求参数（plot_params_json 等） */
const plotParamsJsonDialogVisible = ref(false);
/** 最近一次生成请求提交的作图参数快照 + input_file */
const lastPlotParamsSnapshot = ref(null);

/** 示例 CSV 列表，由 /examples/manifest.json 配置（可放入 public/examples/ 下的文件） */
const exampleFiles = ref([
  {
    file: "/examples/DEG_test.xlsx",
    label_zh: "DEG_test.xlsx（示例）",
    label_en: "DEG_test.xlsx (sample)"
  }
]);

const toolExampleFiles = computed(() => {
  const tool = activeAnalysisTool.value || "bubble";
  return exampleFiles.value.filter((ex) => !ex.tool || ex.tool === tool);
});

const ACCEPT_DEG_EXT = [".csv", ".tsv", ".txt", ".rds", ".xlsx", ".xls"];

function isAcceptedDegFile(name) {
  const n = (name || "").toLowerCase();
  return ACCEPT_DEG_EXT.some((ext) => n.endsWith(ext));
}

function setDegFile(file) {
  if (!file || !isAcceptedDegFile(file.name)) {
    ElMessage.error(t.value.invalidFileType);
    return;
  }
  rawFile.value = file;
  fileLabel.value = file.name;
  barPathwayCustomGeneIds.value = {};
  syncActiveToolStateToStore();
}

function triggerFileInput() {
  fileInputRef.value?.click();
}

function onFileInputChange(e) {
  const input = e.target;
  const f = input.files?.[0];
  if (f) setDegFile(f);
  input.value = "";
}

function onDragEnter() {
  dragDepth.value += 1;
  isDragOver.value = true;
}

function onDragLeave() {
  dragDepth.value = Math.max(0, dragDepth.value - 1);
  if (dragDepth.value === 0) {
    isDragOver.value = false;
  }
}

function onDragOver() {
  /* dragover 需 preventDefault 才能触发 drop */
}

function onFileDrop(e) {
  dragDepth.value = 0;
  isDragOver.value = false;
  const f = e.dataTransfer?.files?.[0];
  if (f) setDegFile(f);
}

/** 与 backend/enrichment_logic.R 中 plot_dims_cm() 一致：按展示通路数估算图宽高 (cm) */
function plotDimsCmFromTopN(nPathways) {
  const xLen = Math.min(100, Math.max(1, Number(nPathways) || 1));
  let h;
  if (xLen < 10) {
    h = 10;
  } else if (xLen < 20) {
    h = 10 + (xLen - 10) / 3;
  } else if (xLen < 100) {
    h = 13 + (xLen - 20) / 5;
  } else {
    h = 40;
  }
  const w = h * 1.5;
  return { width_cm: Math.round(w * 100) / 100, height_cm: Math.round(h * 100) / 100 };
}

const _dimsInitial = plotDimsCmFromTopN(10);

const form = reactive({
  genome: "mmu",
  enrichment_type: "KEGG",
  top_pathways: 10,
  arrange_standard: "pvalue",
  x_axis: "GeneRatio",
  arrange_way: "pvalue",
  show_grid: false,
  grid_major_color: "#d3d3d3",
  grid_major_linewidth: 0.4,
  grid_minor_color: "#e0e0e0",
  grid_minor_linewidth: 0.35,
  color_low: "#487dad",
  color_high: "#bb9cc4",
  plot_title: "",
  x_axis_title: "GeneRatio",
  y_axis_title: "Pathway",
  bubble_size_min: 2,
  bubble_size_max: 6,
  bubble_breaks_custom: "",
  title_size: 14,
  plot_title_bold: false,
  axis_x_title_size: 12,
  axis_y_title_size: 12,
  axis_x_text_size: 9,
  axis_y_text_size: 8,
  axis_x_title_bold: false,
  axis_y_title_bold: false,
  axis_x_text_bold: false,
  axis_y_text_bold: false,
  legend_position: "right",
  legend_color_title: "",
  legend_color_title_size: 11,
  legend_size_title: "",
  legend_size_title_size: 11,
  plot_width_cm: _dimsInitial.width_cm,
  plot_height_cm: _dimsInitial.height_cm,
  dpi: 300,
  colorbar_barwidth_mm: 4.5,
  y_wrap_width: 60,
  axis_y_text_lineheight: 1.12,
  bar_width: 0.45,
  bar_alpha: 0.8,
  bar_y_ticks: false,
  bar_y_tick_length_cm: 0,
  bar_x_expand_left: 0,
  bar_x_expand_right: 0,
  bar_pathway_text_x: 0.001,
  bar_pathway_text_size: 4.3,
  bar_pathway_text_bold: false,
  bar_gene_text_x: 0.001,
  bar_gene_text_vjust: 3,
  bar_gene_text_size: 3,
  bar_show_gene_id: false,
  bar_gene_show_n: 10
});

function buildBubbleFormDefaults(enrichmentType = "KEGG") {
  const d = plotDimsCmFromTopN(10);
  return {
    genome: "mmu",
    enrichment_type: enrichmentType,
    top_pathways: 10,
    arrange_standard: "pvalue",
    x_axis: "GeneRatio",
    arrange_way: "pvalue",
    show_grid: false,
    grid_major_color: "#d3d3d3",
    grid_major_linewidth: 0.4,
    grid_minor_color: "#e0e0e0",
    grid_minor_linewidth: 0.35,
    color_low: "#487dad",
    color_high: "#bb9cc4",
    plot_title: "",
    x_axis_title: "GeneRatio",
    y_axis_title: "Pathway",
    bubble_size_min: 2,
    bubble_size_max: 6,
    bubble_breaks_custom: "",
    title_size: 14,
    plot_title_bold: false,
    axis_x_title_size: 12,
    axis_y_title_size: 12,
    axis_x_text_size: 9,
    axis_y_text_size: 8,
    axis_x_title_bold: false,
    axis_y_title_bold: false,
    axis_x_text_bold: false,
    axis_y_text_bold: false,
    legend_position: "right",
    legend_color_title: "",
    legend_color_title_size: 11,
    legend_size_title: "",
    legend_size_title_size: 11,
    plot_width_cm: d.width_cm,
    plot_height_cm: d.height_cm,
    dpi: 300,
    colorbar_barwidth_mm: 4.5,
    y_wrap_width: 60,
    axis_y_text_lineheight: 1.12,
    bar_width: 0.45,
    bar_alpha: 0.8,
    bar_y_ticks: false,
    bar_y_tick_length_cm: 0,
    bar_x_expand_left: 0,
    bar_x_expand_right: 0,
    bar_pathway_text_x: 0.001,
    bar_pathway_text_size: 4.3,
    bar_pathway_text_bold: false,
    bar_gene_text_x: 0.001,
    bar_gene_text_vjust: 3,
    bar_gene_text_size: 3,
    bar_show_gene_id: false,
    bar_gene_show_n: 10
  };
}

/** 条形图示例/初始参数（与「运行示例」及新建条形图工作区一致） */
const BAR_EXAMPLE_TOP_PATHWAYS = 5;

function buildBarFormDefaults(enrichmentType = "KEGG") {
  const d = plotDimsCmFromTopN(BAR_EXAMPLE_TOP_PATHWAYS);
  return {
    genome: "mmu",
    enrichment_type: enrichmentType,
    top_pathways: BAR_EXAMPLE_TOP_PATHWAYS,
    arrange_standard: "qvalue",
    x_axis: "GeneRatio",
    arrange_way: "qvalue",
    show_grid: false,
    grid_major_color: "#d3d3d3",
    grid_major_linewidth: 0.4,
    grid_minor_color: "#e0e0e0",
    grid_minor_linewidth: 0.35,
    color_low: "#b6abbd",
    color_high: "#624c74",
    plot_title: "",
    x_axis_title: "GeneRatio",
    y_axis_title: "",
    bubble_size_min: 2,
    bubble_size_max: 6,
    bubble_breaks_custom: "",
    title_size: 13,
    plot_title_bold: true,
    axis_x_title_size: 13,
    axis_y_title_size: 13,
    axis_x_text_size: 11,
    axis_y_text_size: 8,
    axis_x_title_bold: true,
    axis_y_title_bold: true,
    axis_x_text_bold: false,
    axis_y_text_bold: false,
    legend_color_title: "",
    legend_color_title_size: 10,
    legend_size_title: "",
    legend_size_title_size: 11,
    legend_position: "right",
    plot_width_cm: d.width_cm,
    plot_height_cm: d.height_cm,
    dpi: 300,
    colorbar_barwidth_mm: 4.5,
    y_wrap_width: 60,
    axis_y_text_lineheight: 1.12,
    bar_width: 0.45,
    bar_alpha: 0.8,
    bar_y_ticks: false,
    bar_y_tick_length_cm: 0,
    bar_x_expand_left: 0,
    bar_x_expand_right: 0,
    bar_pathway_text_x: 0.001,
    bar_pathway_text_size: 4.3,
    bar_pathway_text_bold: false,
    bar_gene_text_x: 0.001,
    bar_gene_text_vjust: 3,
    bar_gene_text_size: 3,
    bar_show_gene_id: true,
    bar_gene_show_n: 10
  };
}

function applyBubbleFormDefaults() {
  Object.assign(
    form,
    buildBubbleFormDefaults(activeTab.value === "kegg" ? "KEGG" : "GO")
  );
}

function applyBarFormDefaults() {
  Object.assign(form, buildBarFormDefaults(activeTab.value === "kegg" ? "KEGG" : "GO"));
}

watch(
  () => form.top_pathways,
  (n) => {
    const d = plotDimsCmFromTopN(n);
    form.plot_width_cm = d.width_cm;
    form.plot_height_cm = d.height_cm;
  }
);

/** 随「显著性 / 颜色映射」联动：p-value 与 q-value 下横坐标、排序可选范围不同 */
const xAxisOptions = computed(() => {
  if (form.arrange_standard === "qvalue") {
    return [
      { label: "GeneRatio", value: "GeneRatio" },
      { label: "RichFactor", value: "RichFactor" },
      { label: "-log10(qvalue)", value: "-log10(qvalue)" }
    ];
  }
  return [
    { label: "GeneRatio", value: "GeneRatio" },
    { label: "RichFactor", value: "RichFactor" },
    { label: "-log10(pvalue)", value: "-log10(pvalue)" }
  ];
});

const sortByOptions = computed(() => {
  if (form.arrange_standard === "qvalue") {
    return [
      { label: "qvalue", value: "qvalue" },
      { label: "RichFactor", value: "RichFactor" },
      { label: "GeneRatio", value: "GeneRatio" }
    ];
  }
  return [
    { label: "pvalue", value: "pvalue" },
    { label: "RichFactor", value: "RichFactor" },
    { label: "GeneRatio", value: "GeneRatio" }
  ];
});

/** 颜色图例标题留空时的默认公式提示（与后端 arrange_standard 一致） */
const legendColorTitlePlaceholder = computed(() =>
  form.arrange_standard === "qvalue" ? "-log10(qvalue)" : "-log10(pvalue)"
);

function plotLegendColorTitleTrimmed(f = form) {
  return String(f.legend_color_title ?? "").trim();
}

watch(
  () => form.arrange_standard,
  (std) => {
    const xP = ["GeneRatio", "RichFactor", "-log10(pvalue)"];
    const xQ = ["GeneRatio", "RichFactor", "-log10(qvalue)"];
    const wP = ["pvalue", "RichFactor", "GeneRatio"];
    const wQ = ["qvalue", "RichFactor", "GeneRatio"];
    if (std === "pvalue") {
      if (!xP.includes(form.x_axis)) {
        form.x_axis =
          form.x_axis === "-logFDR" ||
          form.x_axis === "-log10(qvalue)" ||
          form.x_axis === "negLog10_qvalue"
            ? "-log10(pvalue)"
            : "GeneRatio";
      }
      if (!wP.includes(form.arrange_way)) {
        form.arrange_way = "pvalue";
      }
    } else {
      if (!xQ.includes(form.x_axis)) {
        form.x_axis =
          form.x_axis === "-log10(pvalue)" ||
          form.x_axis === "negLog10_pvalue" ||
          form.x_axis === "-logFDR"
            ? "-log10(qvalue)"
            : "GeneRatio";
      }
      if (!wQ.includes(form.arrange_way)) {
        form.arrange_way = "qvalue";
      }
    }
  },
  { immediate: true }
);

/** 横坐标变量切换时，X 轴标题默认与左侧下拉展示文案一致（仍可手动改） */
watch(
  () => [form.x_axis, xAxisOptions.value],
  () => {
    const hit = xAxisOptions.value.find((o) => o.value === form.x_axis);
    form.x_axis_title = hit ? hit.label : String(form.x_axis ?? "");
  },
  { immediate: true }
);

const i18n = {
  zh: {
    navHome: "首页",
    langSwitchAria: "界面语言",
    navAnalysis: "分析",
    homeStatement: "一个面向组学研究的富集分析平台，帮助你快速自动化完成结果可视化。",
    analyzeNow: "立即分析",
    analysisHubTitle: "富集分析",
    analysisBubblePlot: "富集分析气泡图",
    analysisBarChart: "富集分析条形图",
    analysisSidebarDevNote: "选择左侧工具开始分析",
    analysisSidebarNavExpand: "展开富集分析子菜单",
    analysisSidebarNavCollapse: "收起富集分析子菜单",
    analysisSidebarExpand: "展开导航",
    analysisSidebarCollapse: "收起导航",
    analysisComingSoonBadge: "开发中",
    analysisBarComingSoon: "富集分析条形图正在开发中，敬请期待。",
    analysisBackToHub: "返回富集分析入口",
    logoBrand: "OmicPlot",
    toolName: "富集分析气泡图",
    toolNameBar: "富集分析条形图",
    tagline: "上传差异基因列表，一键完成 KEGG / GO 富集并绘制气泡图",
    taglineBar: "上传差异基因列表，一键完成 KEGG / GO 富集并绘制条形图。",
    modeBarLabel: "富集类型",
    tabKegg: "KEGG 富集",
    tabGo: "GO 富集",
    degFile: "差异基因文件",
    degFileFormats: "（.csv / .txt / .xlsx / .xls）",
    degHint: "支持 .csv / .txt / .xlsx / .xls；需含列名 Gene，输入数据格式参考示例数据。建议小于 20MB；首次分析可能需联网下载注释，因此耗时较长，请耐心等待，如时间过久请检查网络。",
    formatPreview: "格式预览",
    formatPreviewLoading: "正在生成预览…",
    example: "示例",
    selectFile: "选择文件",
    selected: "已选",
    noFileSelected: "未选择文件",
    dropZoneTitle: "上传数据请点击下方「选择文件」按钮。",
    invalidFileType: "仅支持 .csv、.tsv、.txt、.rds、.xlsx、.xls 格式",
    paramGroupAnalysis: "分析与筛选",
    paramGroupDisplay: "图表映射与排序",
    genome: "参考物种",
    enrichType: "富集类型",
    topN: "展示通路数",
    topNPlaceholder: "选择 10 / 20 / 30 或输入 5–100",
    sigStandard: "显著性 / 颜色映射",
    pvalue: "pvalue",
    qvalue: "qvalue",
    xAxis: "横坐标变量",
    sortBy: "排序依据",
    showGrid: "显示网格线",
    showGridOn: "显示",
    showGridOff: "隐藏",
    gridLinesStyle: "网格线样式",
    gridLinesExpand: "展开设置",
    gridLinesCollapse: "收起",
    gridLinesMajor: "主网格线",
    gridLinesMinor: "次网格线",
    gridLineColor: "颜色",
    gridLineWidth: "线宽",
    generate: "生成气泡图",
    generateBar: "生成条形图",
    preview: "结果展示",
    previewDrawingTitle: "正在绘制气泡图…",
    previewDrawingTitleBar: "正在绘制条形图…",
    previewDrawingHint:
      "富集与作图可能需要数十秒至数分钟，请耐心等待，勿关闭或刷新本页；首次分析若下载注释可能更久。",
    previewDrawingHintBar:
      "富集与作图可能需要数十秒至数分钟，请耐心等待，勿关闭或刷新本页；首次分析若下载注释可能更久。",
    previewPlotParams: "查看当前作图参数",
    previewPlotParamsTitle: "当前图表作图参数",
    previewPlotParamsHint:
      "与最近一次成功「生成图表」时提交给后端的全部参数一致；修改左侧或右侧任意设置后，请再次点击「生成图表」以更新图片与本列表。",
    previewPlotParamsClose: "关闭",
    paramAxisXTitleSize: "X 轴标题字号",
    paramAxisYTitleSize: "Y 轴标题字号",
    axisXTitleStyle: "X 轴标题字号",
    axisYTitleStyle: "Y 轴标题字号",
    axisXTickStyle: "X 轴刻度字号",
    axisYTickStyle: "Y 轴刻度字号",
    axisXTitleBold: "X 轴标题加粗",
    axisYTitleBold: "Y 轴标题加粗",
    axisXTextBold: "X 轴刻度加粗",
    axisYTextBold: "Y 轴刻度加粗",
    axisBoldOn: "加粗",
    axisBoldOff: "常规",
    axisBoldMenuTitle: "字体加粗",
    axisBoldMenuOpen: "展开设置",
    axisBoldSummarySome: "加粗项：{list}",
    axisBoldBitMain: "主标题",
    axisBoldBitXTitle: "X 轴标题",
    axisBoldBitYTitle: "Y 轴标题",
    axisBoldBitXTick: "X 轴刻度",
    axisBoldBitYTick: "Y 轴刻度",
    paramLegendPosition: "图例位置",
    paramColorbarBarwidthMm: "图例宽度（mm）",
    previewPlotParamsEmpty: "（尚无记录，请重新生成图表。）",
    downloadPng: "下载 PNG",
    downloadPdf: "下载 PDF",
    downloadPdfUnavailableHint:
      "本次预览未附带可下载的 PDF：常见于服务端 pdf() 导出失败或当前环境不支持矢量输出。请使用「下载 PNG」；若需 PDF，可在本机 R 中检查图形设备或查看 API 返回的 meta.has_pdf。",
    downloadPdfUnavailableHintKnownFalse:
      "服务端已标明本次未生成 PDF（meta.has_pdf 为 false），通常为矢量导出步骤失败。请使用「下载 PNG」。",
    plotImgAlt: "富集气泡图",
    plotImgAltBar: "富集条形图",
    noPlot: "尚未生成图片",
    uploadFirst: "请上传符合格式的基因列表后点击生成。",
    tip1: "KEGG 分析依赖网络，若超时请稍后重试。",
    tip2: "未匹配基因比例过大时服务端会中止并提示检查物种与基因符号。",
    runExample: "运行示例",
    styleBlockPalette: "配色",
    styleBlockPaletteGrid: "配色与网格线",
    styleBlockBar: "条形图样式",
    barWidth: "柱宽",
    barAlpha: "柱透明度",
    barXExpandLeft: "X 轴左侧空隙",
    barXExpandRight: "X 轴右侧空隙",
    barYTicks: "Y 轴刻度线",
    barYTickLengthCm: "Y 轴刻度线长度 (cm)",
    barPathwayTextX: "通路名距 X 轴",
    barPathwayTextSize: "通路名字号",
    barPathwayTextBold: "通路名加粗",
    barShowGeneId: "显示基因 ID",
    barGeneShowN: "展示基因数",
    barGeneTextX: "基因 ID 距 X 轴",
    barGeneTextVjust: "基因 ID 行偏移",
    barGeneTextSize: "基因 ID 字号",
    styleBlockChartText: "标题内容",
    styleBlockBasic: "基础参数",
    styleBlockTypography: "字体与字形",
    styleBlockBubble: "气泡大小与刻度",
    styleBlockLegend: "图例设置",
    styleBlockCanvas: "画布与分辨率",
    legendColorTitleLabel: "颜色图例标题",
    legendColorTitleSizeLabel: "颜色图例标题字号",
    legendSizeTitleLabel: "Count 图例标题",
    legendSizeTitleSizeLabel: "Count 图例标题字号",
    legendColorTitlePlaceholder: "留空=默认公式；自定义文字后请点「生成图表」",
    legendSizeTitlePlaceholder: "留空则为 Count",
    legendColorTitleDefaultShort: "（默认公式）",
    legendSizeTitleDefaultShort: "Count",
    legendPosRight: "右侧",
    legendPosLeft: "左侧",
    legendPosBottom: "下方",
    legendPosTop: "上方",
    legendCompactColorTitle: "颜色标题",
    legendCompactColorTitleBarHint: "留空为默认 -log10(q/p)；填写自定义文字后请点「生成图表」",
    legendCompactColorSize: "颜色标题字号",
    legendCompactCountTitle: "Count标题",
    legendCompactCountSize: "Count字号",
    legendCompactBarwidth: "色条宽",
    legendCompactPosition: "位置",
    legendCompactColorTitlePh: "默认公式",
    legendCompactCountTitlePh: "默认Count",
    plotTitleStyle: "图表标题样式",
    styleSection: "样式与参数",
    colorLow: "低显著性颜色",
    colorHigh: "高显著性颜色",
    plotTitle: "图表标题",
    xTitle: "X 轴标题",
    yTitle: "Y 轴标题",
    bubbleMin: "气泡大小下限",
    bubbleMax: "气泡大小上限",
    bubbleBreaks: "气泡刻度（可选）",
    bubbleBreaksHelpChip: "说明",
    bubbleBreaksHelpAria: "查看气泡刻度用法说明",
    bubbleBreaksHelpTitle: "气泡刻度说明",
    bubbleBreaksHelpAutoHead: "一、留空（默认自动）",
    bubbleBreaksHelpAutoBody:
      "后端根据当前图中各通路基因数 Count 的最小值与最大值，自动生成 4 个递增数值，用作右侧「Count」大小图例上的刻度（数字及示意小圆点）。算法会按 Count 跨度选择合适间隔，再整理为恰好 4 个落在数据附近的有限值。展示通路数或数据变化导致 Count 范围变化时，自动刻度也可能随之变化。",
    bubbleBreaksHelpManualHead: "二、手动填写",
    bubbleBreaksHelpManualBody:
      "在输入框中填入若干数字（与基因数 Count 同一量级），用于指定图例上希望标出的 Count 刻度。仅影响图例刻度展示；点的大小仍由「气泡大小下限/上限」把 Count 映射到圆点大小。",
    bubbleBreaksHelpFormatHead: "三、分隔符与示例",
    bubbleBreaksHelpFormatBody:
      "可用英文逗号、空格、英文分号或竖线 | 分隔；也支持中文逗号 ，、顿号 、、全角分号 ；。示例：15,20,25,30 或 15，20，25，30 或 10 20 30 40。",
    bubbleBreaksHelpNote: "若解析后有效数字少于 2 个，将自动退回「自动刻度」。",
    bubbleBreaksPh: "留空则自动，若需修改刻度则可手动添加，具体见说明",
    titleSize: "标题字号",
    axisXText: "X 轴刻度字号",
    axisYText: "Y 轴刻度字号",
    pathwayWrapWidth: "通路名换行宽度",
    axisYLineheightLabel: "Y 轴换行行距",
    plotW: "图宽度 (cm)",
    plotH: "图高度 (cm)",
    dpi: "分辨率",
    auto: "自动",
    styleCardTabsAria: "样式与结果切换",
    statsTab: "统计结果",
    statsComingTitle: "统计结果",
    statsComingHint: "请先在左侧上传基因列表并点击「生成气泡图」。生成成功后，这里会展示按当前作图参数排序后的条目，并提供全量与排序视图的 CSV 下载。",
    statsComingHintBar: "请先在左侧上传基因列表并点击「生成条形图」。生成成功后，这里会展示按当前作图参数排序后的条目，并提供全量与排序视图的 CSV 下载。",
    statsKpi1: "富集条目（全量）",
    statsKpi2: "展示条目（按参数）",
    statsKpi3: "输入基因数",
    statsRawCap: "全量富集结果（未按作图参数重排）",
    statsRawHint: "下载内容与 clusterProfiler 返回的富集表一致，不在此完整展开。",
    statsDlRaw: "下载全量 CSV",
    statsSortedCap: "按作图参数排序后的结果",
    statsSortedHint: "排序与气泡图一致：先按「显著性标准」筛 TopN，再按「排序依据」与「横坐标变量」重排。",
    statsDlSorted: "下载当前表格 CSV",
    statsTableTitle: "结果表",
    statsPageShow: "每页显示",
    statsPageCustom: "自定义",
    statsRowsTotal: "共 {n} 条",
    pathwayPickerLabel: "目标通路",
    pathwayPickerPlaceholder: "选择一个通路后可查看详情并设置标红",
    pathwayPickerAction: "查看/标红",
    pathwayPickerPlaceholderBar: "选择一个通路后可查看详情或自定义基因 ID",
    pathwayPickerActionBar: "查看详情/自定义添加基因ID",
    pathwayGeneCustomTitle: "自定义通路基因 ID（条形图）",
    pathwayGeneCustomHint:
      "开启「显示基因 ID」后，此处设置的 ID 将替代系统按「展示基因数」自动截取的前 N 个基因，显示在图上该通路旁。",
    pathwayGeneAutoLabel: "当前自动截取（未自定义时生效）",
    pathwayGeneAutoNote: "保存自定义后，上图将只显示您填写的基因 ID，不再使用左侧自动列表。",
    pathwayGeneCustomActiveLabel: "当前已使用自定义基因 ID",
    pathwayGeneCustomInputLabel: "自定义基因 ID",
    pathwayGeneCustomInputPlaceholder: "多个基因用英文逗号、中文逗号、换行或 / 分隔，例如：Tp53,Mdm2,Cdkn1a",
    pathwayGeneCustomApply: "保存自定义",
    pathwayGeneCustomClear: "恢复自动截取",
    pathwayGeneCustomFoot: "保存后请重新点击左侧「生成条形图」使修改生效。",
    pathwayGeneCustomApplied: "已保存该通路的自定义基因 ID",
    pathwayGeneCustomCleared: "已恢复为自动截取基因 ID",
    previewPathwayHintBar: "提示：请先在上方选择目标通路，再打开弹窗查看详情。",
    plotConfirmTitle: "绘图参数确认",
    plotConfirmHint: "请确认本次分析与样式参数（含左侧分析与右侧样式面板）。确认后将按当前全部设置生成图表。",
    plotConfirmChangesIntro: "相对上次成功作图，以下参数已修改：",
    plotConfirmCancel: "返回修改",
    plotConfirmActionGenerate: "确认并生成",
    plotConfirmFile: "输入文件",
    plotConfirmGenome: "参考物种",
    plotConfirmEnrichment: "富集类型",
    plotConfirmTopN: "展示通路数",
    plotConfirmSigStd: "显著性标准",
    plotConfirmXAxis: "横坐标变量",
    plotConfirmSort: "排序依据",
    plotConfirmSizeRange: "气泡大小范围",
    plotConfirmCanvas: "画布参数",
    plotConfirmHighlight: "标红通路",
    plotConfirmHighlightNone: "无",
    plotConfirmHighlightCountSuffix: "条",
    plotConfirmBarCustomGeneIds: "自定义通路基因 ID",
    plotConfirmBarCustomGeneAuto: "无（各通路按「展示基因数」自动截取）",
    pathwayGeneIdFieldLabel: "通路基因 (geneID)",
    previewPathwayHint: "提示：请先在上方选择目标通路，再打开弹窗查看详情并设置是否标红。",
    pathwayHighlightPanelTitle: "科研绘图：通路名称标红",
    pathwayHighlightPanelHint:
      "打开后，当前通路会在最终导出的图中以红色显示（仅标红你勾选的通路名称）。切换标红后请点击左侧「生成图表」使改动生效。",
    pathwayHighlightOn: "标红",
    pathwayHighlightOff: "不标红",
    pathwayHitAria: "气泡图左侧通路区域，可按行点击查看详情",
    pathwayDetailHintFull: "以下为 clusterProfiler 富集表中该条目的完整字段。",
    pathwayDetailHintPartial: "未在完整富集表中找到完全相同的 Description，以下为当前作图用表中的字段。"
  },
  en: {
    navHome: "Home",
    langSwitchAria: "Interface language",
    navAnalysis: "Analysis",
    homeStatement: "An enrichment analysis platform for omics research, helping you quickly automate result visualization.",
    analyzeNow: "Analyze now",
    analysisHubTitle: "Enrichment analysis",
    analysisBubblePlot: "Enrichment bubble plot",
    analysisBarChart: "Enrichment bar chart",
    analysisSidebarDevNote: "Pick a tool on the left to start",
    analysisSidebarNavExpand: "Expand enrichment submenu",
    analysisSidebarNavCollapse: "Collapse enrichment submenu",
    analysisSidebarExpand: "Expand sidebar",
    analysisSidebarCollapse: "Collapse sidebar",
    analysisComingSoonBadge: "Coming soon",
    analysisBarComingSoon: "The enrichment bar chart is under development. Stay tuned.",
    analysisBackToHub: "Back to enrichment hub",
    logoBrand: "OmicPlot",
    toolName: "Enrichment bubble plot",
    toolNameBar: "Enrichment bar chart",
    tagline: "Upload a DEG list for KEGG/GO enrichment and bubble plot.",
    taglineBar: "Upload a DEG list for KEGG/GO enrichment and bar chart.",
    modeBarLabel: "Enrichment type",
    tabKegg: "KEGG",
    tabGo: "GO",
    degFile: "Gene list file",
    degFileFormats: " (.csv / .tsv / .txt / .rds / .xlsx / .xls)",
    degHint: "Formats: .csv, .tsv, .txt, .rds, .xlsx, .xls. Column Gene required. Excel uses the first sheet. First run may download annotation.",
    formatPreview: "Preview",
    formatPreviewLoading: "Generating preview…",
    example: "Example",
    selectFile: "Select file",
    selected: "Selected",
    noFileSelected: "No file selected",
    dropZoneTitle: "Drag a file into the dashed box, or click \"Select file\" below.",
    invalidFileType: "Only .csv, .tsv, .txt, .rds, .xlsx, .xls are allowed",
    paramGroupAnalysis: "Analysis & filtering",
    paramGroupDisplay: "Plot mapping & order",
    genome: "Species",
    enrichType: "Enrichment",
    topN: "Pathways to show",
    topNPlaceholder: "Pick 10 / 20 / 30 or type 5–100",
    sigStandard: "Significance for color",
    pvalue: "pvalue",
    qvalue: "qvalue",
    xAxis: "X-axis variable",
    sortBy: "Sort by",
    showGrid: "Show grid lines",
    showGridOn: "On",
    showGridOff: "Off",
    gridLinesStyle: "Grid lines",
    gridLinesExpand: "Expand settings",
    gridLinesCollapse: "Collapse",
    gridLinesMajor: "Major grid",
    gridLinesMinor: "Minor grid",
    gridLineColor: "Color",
    gridLineWidth: "Line width",
    generate: "Generate plot",
    generateBar: "Generate bar chart",
    preview: "Results",
    previewDrawingTitle: "Drawing bubble plot…",
    previewDrawingTitleBar: "Drawing bar chart…",
    previewDrawingHint:
      "Enrichment and plotting may take from tens of seconds to a few minutes. Please wait and do not refresh this page; the first run may take longer if annotations are downloaded.",
    previewDrawingHintBar:
      "Enrichment and plotting may take from tens of seconds to a few minutes. Please wait and do not refresh this page; the first run may take longer if annotations are downloaded.",
    previewPlotParams: "Plot parameters",
    previewPlotParamsTitle: "Parameters for this figure",
    previewPlotParamsHint:
      "Matches all parameters submitted with your last successful generate. Change settings and generate again to refresh the figure and this list.",
    previewPlotParamsClose: "Close",
    paramAxisXTitleSize: "X-axis title size",
    paramAxisYTitleSize: "Y-axis title size",
    axisXTitleStyle: "X-axis title style",
    axisYTitleStyle: "Y-axis title style",
    axisXTickStyle: "X-axis tick style",
    axisYTickStyle: "Y-axis tick style",
    axisXTitleBold: "X-axis title bold",
    axisYTitleBold: "Y-axis title bold",
    axisXTextBold: "X-axis tick bold",
    axisYTextBold: "Y-axis tick bold",
    axisBoldOn: "Bold",
    axisBoldOff: "Regular",
    axisBoldMenuTitle: "Bold by text layer",
    axisBoldMenuOpen: "Expand to adjust each",
    axisBoldSummaryNone: "All layers are regular weight",
    axisBoldSummarySome: "Bold: {list}",
    axisBoldBitMain: "Plot title",
    axisBoldBitXTitle: "X-axis title",
    axisBoldBitYTitle: "Y-axis title",
    axisBoldBitXTick: "X-axis ticks",
    axisBoldBitYTick: "Y-axis ticks",
    paramLegendPosition: "Legend position",
    paramColorbarBarwidthMm: "Color bar width (mm)",
    previewPlotParamsEmpty: "(No snapshot yet — generate the plot again.)",
    downloadPng: "Download PNG",
    downloadPdf: "Download PDF",
    downloadPdfUnavailableHint:
      "No downloadable PDF was attached to this preview (vector export often fails on some headless/Windows setups). Use Download PNG; for PDF, check R pdf() support or the API field meta.has_pdf.",
    downloadPdfUnavailableHintKnownFalse:
      "The server reported no PDF for this run (meta.has_pdf is false), usually because vector export failed. Use Download PNG.",
    plotImgAlt: "Enrichment bubble plot",
    plotImgAltBar: "Enrichment bar chart",
    noPlot: "No plot yet",
    uploadFirst: "Upload a valid file and click generate.",
    tip1: "KEGG needs network; retry if timeout.",
    tip2: "Server stops if more than 20% of genes fail ID mapping.",
    runExample: "Run example",
    styleBlockPalette: "Palette",
    styleBlockPaletteGrid: "Palette & grid",
    styleBlockBar: "Bar chart style",
    barWidth: "Bar width",
    barAlpha: "Bar opacity",
    barXExpandLeft: "X padding (left)",
    barXExpandRight: "X padding (right)",
    barYTicks: "Y-axis ticks",
    barYTickLengthCm: "Y tick length (cm)",
    barPathwayTextX: "Pathway label X offset",
    barPathwayTextSize: "Pathway label size",
    barPathwayTextBold: "Pathway label bold",
    barShowGeneId: "Show gene IDs",
    barGeneShowN: "Genes to show",
    barGeneTextX: "Gene ID X offset",
    barGeneTextVjust: "Gene ID row offset",
    barGeneTextSize: "Gene ID font size",
    styleBlockChartText: "Chart text",
    styleBlockBasic: "Basic parameters",
    styleBlockTypography: "Font sizes & weight",
    styleBlockBubble: "Bubble size & breaks",
    styleBlockLegend: "Legend settings",
    styleBlockCanvas: "Canvas & export",
    legendColorTitleLabel: "Color legend title",
    legendColorTitleSizeLabel: "Color legend title size",
    legendSizeTitleLabel: "Count legend title",
    legendSizeTitleSizeLabel: "Count legend title size",
    legendColorTitlePlaceholder: "Empty = default formula; then click Generate to apply",
    legendSizeTitlePlaceholder: "Empty = Count",
    legendColorTitleDefaultShort: "(default expression)",
    legendSizeTitleDefaultShort: "Count",
    legendPosRight: "Right",
    legendPosLeft: "Left",
    legendPosBottom: "Bottom",
    legendPosTop: "Top",
    legendCompactColorTitle: "Color title",
    legendCompactColorSize: "Color pt",
    legendCompactCountTitle: "Count title",
    legendCompactCountSize: "Count pt",
    legendCompactBarwidth: "Bar mm",
    legendCompactPosition: "Pos.",
    legendCompactColorTitlePh: "Default expr.",
    legendCompactCountTitlePh: "Default Count",
    plotTitleStyle: "Main title style",
    styleSection: "Style",
    colorLow: "Low color",
    colorHigh: "High color",
    plotTitle: "Title",
    xTitle: "X title",
    yTitle: "Y title",
    bubbleMin: "Size min",
    bubbleMax: "Size max",
    bubbleBreaks: "Size breaks",
    bubbleBreaksHelpChip: "Help",
    bubbleBreaksHelpAria: "Open help for bubble legend breaks",
    bubbleBreaksHelpTitle: "Bubble legend breaks (Count)",
    bubbleBreaksHelpAutoHead: "1. Leave empty (auto)",
    bubbleBreaksHelpAutoBody:
      "The server uses the min and max Count in the current plot, then builds four ascending values for the right-hand Count size legend (numbers and reference circles). Step size adapts to the span (rounding by tens, etc.), then values are adjusted to exactly four finite breaks near your data. If Top N or data changes the Count range, auto breaks may change too.",
    bubbleBreaksHelpManualHead: "2. Custom values",
    bubbleBreaksHelpManualBody:
      "Enter numbers on the same scale as Count to pin legend ticks. This does not change the underlying Count→point-size mapping limits (those are the bubble min/max size fields).",
    bubbleBreaksHelpFormatHead: "3. Separators & examples",
    bubbleBreaksHelpFormatBody:
      "Use comma, space, semicolon, or pipe |. Chinese punctuation is OK: ，、；. Examples: 15,20,25,30 or 15，20，25，30 or 10 20 30 40.",
    bubbleBreaksHelpNote: "If fewer than two valid numbers are parsed, auto breaks are used instead.",
    bubbleBreaksPh: "Auto if empty. Custom: 15,20,25,30 (comma/space/semicolon; Chinese ，、； OK)",
    titleSize: "Title size",
    axisXText: "X text size",
    axisYText: "Y tick label size",
    pathwayWrapWidth: "Pathway name wrap width",
    axisYLineheightLabel: "Y-axis wrapped line height",
    plotW: "Width (cm)",
    plotH: "Height (cm)",
    dpi: "Resolution",
    auto: "Auto",
    styleCardTabsAria: "Style and statistics tabs",
    statsTab: "Statistics",
    statsComingTitle: "Statistics",
    statsComingHint:
      "Upload a gene list and click Generate. After a successful run, this tab shows the pathway table ordered with your current plot parameters, plus CSV downloads for full and sorted views.",
    statsComingHintBar:
      "Upload a gene list and click Generate bar chart. After a successful run, this tab shows the pathway table ordered with your current plot parameters, plus CSV downloads for full and sorted views.",
    statsKpi1: "All enriched terms",
    statsKpi2: "Displayed (params)",
    statsKpi3: "Input genes",
    statsRawCap: "Full enrichment table (unsorted)",
    statsRawHint: "CSV matches clusterProfiler output; not fully rendered here.",
    statsDlRaw: "Download full CSV",
    statsSortedCap: "Sorted by plot parameters",
    statsSortedHint: "Same ordering as the bubble plot: TopN by significance, then tie-break by sort mapping.",
    statsDlSorted: "Download table CSV",
    statsTableTitle: "Results",
    statsPageShow: "Rows per page",
    statsPageCustom: "Custom",
    statsRowsTotal: "{n} rows",
    pathwayPickerLabel: "Target pathway",
    pathwayPickerPlaceholder: "Select a pathway to view details and red highlight option",
    pathwayPickerAction: "View / highlight",
    pathwayPickerPlaceholderBar: "Select a pathway to view or customize gene IDs",
    pathwayPickerActionBar: "Details / custom gene IDs",
    pathwayGeneCustomTitle: "Custom pathway gene IDs (bar chart)",
    pathwayGeneCustomHint:
      "When “Show gene IDs” is on, labels here override the automatic top-N list for this pathway on the plot.",
    pathwayGeneAutoLabel: "Automatic top-N preview (used when no custom list)",
    pathwayGeneAutoNote: "After saving custom IDs, only your list is drawn—not the automatic preview above.",
    pathwayGeneCustomActiveLabel: "Custom gene IDs in use",
    pathwayGeneCustomInputLabel: "Custom gene IDs",
    pathwayGeneCustomInputPlaceholder: "Separate genes with comma, newline, or /. Example: Tp53,Mdm2,Cdkn1a",
    pathwayGeneCustomApply: "Save custom list",
    pathwayGeneCustomClear: "Use automatic top-N again",
    pathwayGeneCustomFoot: "Click Generate bar chart on the left to apply changes.",
    pathwayGeneCustomApplied: "Custom gene IDs saved for this pathway",
    pathwayGeneCustomCleared: "Restored automatic gene IDs for this pathway",
    previewPathwayHintBar: "Tip: select a pathway above, then open the dialog for details.",
    plotConfirmTitle: "Confirm plotting parameters",
    plotConfirmHint:
      "Review analysis and style settings (left panel + style tab). The plot uses all current values when you confirm.",
    plotConfirmChangesIntro: "Changed since your last successful plot:",
    plotConfirmCancel: "Back",
    plotConfirmActionGenerate: "Confirm and generate",
    plotConfirmFile: "Input file",
    plotConfirmGenome: "Species",
    plotConfirmEnrichment: "Enrichment type",
    plotConfirmTopN: "Top pathways",
    plotConfirmSigStd: "Significance standard",
    plotConfirmXAxis: "X-axis variable",
    plotConfirmSort: "Sort by",
    plotConfirmSizeRange: "Bubble size range",
    plotConfirmCanvas: "Canvas",
    plotConfirmHighlight: "Highlighted pathways",
    plotConfirmHighlightNone: "None",
    plotConfirmHighlightCountSuffix: "items",
    plotConfirmBarCustomGeneIds: "Custom pathway gene IDs",
    plotConfirmBarCustomGeneAuto: "None (automatic top-N per pathway)",
    pathwayGeneIdFieldLabel: "Pathway genes (geneID)",
    previewPathwayHint:
      "Tip: select a target pathway above, then open the dialog to view details and toggle red highlighting.",
    pathwayHighlightOutsideNote:
      "Figure tip: in pathway details dialog, you can enable red label highlighting for target pathways.",
    pathwayHighlightPanelTitle: "Figure-ready option: highlight pathway label",
    pathwayHighlightPanelHint:
      "When enabled, this pathway name is rendered in red. Click Generate on the left to apply highlight changes.",
    pathwayHighlightOn: "Highlight red",
    pathwayHighlightOff: "Normal",
    pathwayHitAria: "Pathway rows on the left of the bubble plot — click a row for details",
    pathwayDetailHintFull: "All columns from the enrichment result for this term.",
    pathwayDetailHintPartial:
      "No exact Description match in the full table; showing fields from the current plot table only."
  }
};

const t = computed(() => i18n[lang.value] || i18n.zh);

const toolUi = computed(() => {
  const row = t.value;
  if (isBarTool.value) {
    return {
      toolName: row.toolNameBar,
      tagline: row.taglineBar,
      generate: row.generateBar,
      previewDrawingTitle: row.previewDrawingTitleBar,
      previewDrawingHint: row.previewDrawingHintBar,
      plotImgAlt: row.plotImgAltBar,
      statsComingHint: row.statsComingHintBar,
      pathwayPickerPlaceholder: row.pathwayPickerPlaceholderBar,
      pathwayPickerAction: row.pathwayPickerActionBar,
      previewPathwayHint: row.previewPathwayHintBar
    };
  }
  return {
    toolName: row.toolName,
    tagline: row.tagline,
    generate: row.generate,
    previewDrawingTitle: row.previewDrawingTitle,
    previewDrawingHint: row.previewDrawingHint,
    plotImgAlt: row.plotImgAlt,
    statsComingHint: row.statsComingHint,
    pathwayPickerPlaceholder: row.pathwayPickerPlaceholder,
    pathwayPickerAction: row.pathwayPickerAction,
    previewPathwayHint: row.previewPathwayHint
  };
});

/** 后端 jsonlite 可能把标量包成单元素数组 */
function rScalarMeta(x) {
  if (Array.isArray(x) && x.length === 1) {
    return x[0];
  }
  return x;
}

const pdfDownloadUnavailableHint = computed(() => {
  if (plotPdfObjectUrl.value) {
    return "";
  }
  const row = t.value;
  const hp = statsMeta.value && rScalarMeta(statsMeta.value.has_pdf);
  if (hp === false || hp === 0) {
    return row.downloadPdfUnavailableHintKnownFalse;
  }
  return row.downloadPdfUnavailableHint;
});

const pathwayDetailHintText = computed(() => {
  const row = t.value;
  return pathwayDetailIsFull.value ? row.pathwayDetailHintFull : row.pathwayDetailHintPartial;
});

const pathwayDetailRowForDialog = computed(() => {
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) return null;
  return statsDisplayRows.value.find((r) => String(r.Description ?? "") === desc) ?? null;
});

function formatAutoBarGeneIdsLabel(geneIdRaw, topN) {
  const parts = String(geneIdRaw ?? "")
    .split("/")
    .map((s) => s.trim())
    .filter(Boolean);
  const n = Math.max(1, Number(topN) || 10);
  const take = parts.slice(0, n);
  if (!take.length) {
    return lang.value === "zh" ? "（无）" : "(none)";
  }
  const label = take.join(",");
  return parts.length > take.length ? `${label}...` : label;
}

function normalizeCustomBarGeneIdsText(raw) {
  const parts = String(raw ?? "")
    .split(/[,/\n;\r\t]+/)
    .map((s) => s.trim())
    .filter(Boolean);
  return parts.join(",");
}

const pathwayGeneCustomActive = computed(() => {
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) return false;
  const v = barPathwayCustomGeneIds.value[desc];
  return typeof v === "string" && v.trim().length > 0;
});

const pathwayAutoGeneIdsText = computed(() => {
  const row = pathwayDetailRowForDialog.value;
  if (!row) return "";
  return formatAutoBarGeneIdsLabel(row.geneID, form.bar_gene_show_n);
});

const pathwayGeneCustomDisplayText = computed(() => {
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) return "";
  return barPathwayCustomGeneIds.value[desc] || "";
});

function formatPathwayAllGeneIds(geneIdRaw) {
  const parts = String(geneIdRaw ?? "")
    .split("/")
    .map((s) => s.trim())
    .filter(Boolean);
  if (!parts.length) {
    return lang.value === "zh" ? "（无）" : "(none)";
  }
  return parts.join(", ");
}

const pathwayDetailEntriesDisplay = computed(() =>
  pathwayDetailEntries.value.map((e) =>
    e.key === "geneID" ? { ...e, value: formatPathwayAllGeneIds(e.value) } : e
  )
);

function getBarPathwayCustomGeneIdsJson() {
  const entries = Object.entries(barPathwayCustomGeneIds.value).filter(
    ([, v]) => String(v).trim().length > 0
  );
  if (!entries.length) return "";
  return JSON.stringify(Object.fromEntries(entries));
}

function confirmFlagOn(v) {
  return ["1", "true", "yes", "on"].includes(String(v ?? "").toLowerCase().trim());
}

function confirmEmptyLabel(isZh) {
  return isZh ? "（空）" : "(empty)";
}

function confirmNz(v, emptyLbl) {
  const x = v == null ? "" : String(v).trim();
  return x.length ? x : emptyLbl;
}

function confirmValuesEqual(a, b) {
  const na = a == null ? "" : String(a).trim();
  const nb = b == null ? "" : String(b).trim();
  const emptySet = new Set(["", "（空）", "(empty)"]);
  if (emptySet.has(na) && emptySet.has(nb)) return true;
  return na === nb;
}

function normalizeBarCustomGeneIdsJsonForCompare(jsonStr) {
  const s = String(jsonStr ?? "").trim();
  if (!s) return "";
  try {
    const o = JSON.parse(s);
    if (!o || typeof o !== "object" || Array.isArray(o)) {
      return s;
    }
    const keys = Object.keys(o).sort();
    const norm = {};
    for (const k of keys) {
      const v = normalizeCustomBarGeneIdsText(String(o[k] ?? ""));
      if (v) {
        norm[k] = v;
      }
    }
    return JSON.stringify(norm);
  } catch {
    return s;
  }
}

function formatBarCustomGeneIdsConfirmValue(row, bag, isZh) {
  const raw = String(bag.bar_custom_gene_ids_json ?? "").trim();
  if (!raw) {
    return row.plotConfirmBarCustomGeneAuto;
  }
  let map;
  try {
    map = JSON.parse(raw);
  } catch {
    return raw;
  }
  if (!map || typeof map !== "object" || Array.isArray(map)) {
    return row.plotConfirmBarCustomGeneAuto;
  }
  const entries = Object.entries(map).filter(([, v]) => String(v).trim());
  if (!entries.length) {
    return row.plotConfirmBarCustomGeneAuto;
  }
  const sep = isZh ? "；" : "; ";
  return entries.map(([name, genes]) => `${name} → ${genes}`).join(sep);
}

function formatHighlightConfirmValue(row, bag, isZh) {
  const raw = String(bag.highlight_terms ?? "").trim();
  const parts = raw.length
    ? raw.split(/\r?\n|[;,|]/).map((x) => x.trim()).filter(Boolean)
    : [];
  if (!bag.highlight_enabled || !parts.length) {
    return row.plotConfirmHighlightNone;
  }
  const sep = isZh ? "；" : "; ";
  const head = parts.slice(0, 20).join(sep);
  const more = parts.length > 20 ? (isZh ? " …" : " ...") : "";
  return `${parts.length} ${row.plotConfirmHighlightCountSuffix}${isZh ? "：" : ": "}${head}${more}`;
}

function formatAxisBoldConfirmValue(row, bag, isZh) {
  const sep = isZh ? "、" : ", ";
  const bits = [];
  if (bag.plot_title_bold) bits.push(row.axisBoldBitMain);
  if (bag.axis_x_title_bold) bits.push(row.axisBoldBitXTitle);
  if (bag.axis_y_title_bold) bits.push(row.axisBoldBitYTitle);
  if (bag.axis_x_text_bold) bits.push(row.axisBoldBitXTick);
  if (bag.axis_y_text_bold) bits.push(row.axisBoldBitYTick);
  if (bag.bar_pathway_text_bold) bits.push(row.barPathwayTextBold);
  if (!bits.length) return row.axisBoldSummaryNone;
  return row.axisBoldSummarySome.replace("{list}", bits.join(sep));
}

/** 确认弹窗各行对应的 API 字段（与 buildPlotParamsApiObject / 快照一致） */
const CONFIRM_ROW_COMPARE_KEYS = {
  file: ["input_file"],
  genome: ["genome"],
  enrichment: ["enrichment_type"],
  topN: ["top_pathways"],
  sigStd: ["arrange_standard"],
  xAxis: ["x_axis"],
  sort: ["arrange_way"],
  showGrid: ["show_grid"],
  gridStyle: ["grid_major_color", "grid_major_linewidth", "grid_minor_color", "grid_minor_linewidth"],
  colorLow: ["color_low"],
  colorHigh: ["color_high"],
  plotTitle: ["plot_title"],
  xTitle: ["x_axis_title"],
  yTitle: ["y_axis_title"],
  barWidth: ["bar_width"],
  barAlpha: ["bar_alpha"],
  barXExpandLeft: ["bar_x_expand_left"],
  barXExpandRight: ["bar_x_expand_right"],
  barYTicks: ["bar_y_ticks"],
  barYTickLengthCm: ["bar_y_tick_length_cm"],
  barPathwayTextX: ["bar_pathway_text_x"],
  barPathwayTextSize: ["bar_pathway_text_size"],
  barShowGeneId: ["bar_show_gene_id"],
  barGeneShowN: ["bar_gene_show_n"],
  barGeneTextX: ["bar_gene_text_x"],
  barGeneTextVjust: ["bar_gene_text_vjust"],
  barGeneTextSize: ["bar_gene_text_size"],
  barCustomGeneIds: ["bar_custom_gene_ids_json"],
  bubbleSize: ["bubble_size_min", "bubble_size_max"],
  bubbleBreaks: ["bubble_breaks_custom"],
  legendPos: ["legend_position"],
  legendColorTitle: ["legend_color_title"],
  legendColorTitleSize: ["legend_color_title_size"],
  legendSizeTitle: ["legend_size_title"],
  legendSizeTitleSize: ["legend_size_title_size"],
  colorbarWidth: ["colorbar_barwidth_mm"],
  titleSize: ["title_size"],
  axisXTitleSize: ["axis_x_title_size"],
  axisYTitleSize: ["axis_y_title_size"],
  axisXText: ["axis_x_text_size"],
  axisYText: ["axis_y_text_size"],
  yWrap: ["y_wrap_width"],
  yLineheight: ["axis_y_text_lineheight"],
  axisBold: [
    "plot_title_bold",
    "axis_x_title_bold",
    "axis_y_title_bold",
    "axis_x_text_bold",
    "axis_y_text_bold",
    "bar_pathway_text_bold"
  ],
  canvas: ["plot_width_cm", "plot_height_cm", "dpi"],
  highlight: ["highlight_terms_enabled", "highlight_terms"]
};

const CONFIRM_COLOR_API_KEYS = new Set([
  "color_low",
  "color_high",
  "grid_major_color",
  "grid_minor_color"
]);

const CONFIRM_NUMERIC_API_KEYS = new Set([
  "top_pathways",
  "grid_major_linewidth",
  "grid_minor_linewidth",
  "bubble_size_min",
  "bubble_size_max",
  "legend_color_title_size",
  "legend_size_title_size",
  "colorbar_barwidth_mm",
  "title_size",
  "axis_x_title_size",
  "axis_y_title_size",
  "axis_x_text_size",
  "axis_y_text_size",
  "y_wrap_width",
  "axis_y_text_lineheight",
  "dpi",
  "bar_width",
  "bar_alpha",
  "bar_x_expand_left",
  "bar_x_expand_right",
  "bar_y_tick_length_cm",
  "bar_pathway_text_x",
  "bar_pathway_text_size",
  "bar_gene_show_n",
  "bar_gene_text_x",
  "bar_gene_text_vjust",
  "bar_gene_text_size",
  "plot_width_cm",
  "plot_height_cm"
]);

function confirmApiValuesEqual(apiKey, a, b) {
  let na = a == null ? "" : String(a).trim();
  let nb = b == null ? "" : String(b).trim();
  if (CONFIRM_COLOR_API_KEYS.has(apiKey)) {
    const ha = tryNormalizeColorToHex(na) ?? na.toLowerCase();
    const hb = tryNormalizeColorToHex(nb) ?? nb.toLowerCase();
    return ha === hb;
  }
  if (CONFIRM_NUMERIC_API_KEYS.has(apiKey)) {
    const fa = Number(na);
    const fb = Number(nb);
    if (!Number.isNaN(fa) && !Number.isNaN(fb)) {
      return Math.abs(fa - fb) < 1e-9;
    }
  }
  if (apiKey === "show_grid" || apiKey.endsWith("_bold") || apiKey === "bar_y_ticks" || apiKey === "bar_show_gene_id") {
    return confirmFlagOn(a) === confirmFlagOn(b);
  }
  if (apiKey === "highlight_terms_enabled") {
    return confirmFlagOn(a) === confirmFlagOn(b);
  }
  if (apiKey === "bar_custom_gene_ids_json") {
    return (
      normalizeBarCustomGeneIdsJsonForCompare(na) === normalizeBarCustomGeneIdsJsonForCompare(nb)
    );
  }
  return confirmValuesEqual(na, nb);
}

function isConfirmRowChanged(rowId, curApi, prevApi) {
  if (!prevApi || !curApi) return false;
  const keys = CONFIRM_ROW_COMPARE_KEYS[rowId];
  if (!keys?.length) return false;
  return keys.some((k) => !confirmApiValuesEqual(k, curApi[k], prevApi[k]));
}

function snapshotToConfirmBag(s) {
  return {
    input_file: s.input_file ?? "",
    genome: s.genome ?? "",
    enrichment_type: s.enrichment_type ?? "",
    top_pathways: String(s.top_pathways ?? ""),
    arrange_standard: s.arrange_standard ?? "",
    x_axis: s.x_axis ?? "",
    arrange_way: s.arrange_way ?? "",
    show_grid: confirmFlagOn(s.show_grid),
    grid_major_color: s.grid_major_color ?? "",
    grid_major_linewidth: String(s.grid_major_linewidth ?? ""),
    grid_minor_color: s.grid_minor_color ?? "",
    grid_minor_linewidth: String(s.grid_minor_linewidth ?? ""),
    color_low: s.color_low ?? "",
    color_high: s.color_high ?? "",
    plot_title: s.plot_title ?? "",
    x_axis_title: s.x_axis_title ?? "",
    y_axis_title: s.y_axis_title ?? "",
    bar_width: String(s.bar_width ?? ""),
    bar_alpha: String(s.bar_alpha ?? ""),
    bar_x_expand_left: String(s.bar_x_expand_left ?? ""),
    bar_x_expand_right: String(s.bar_x_expand_right ?? ""),
    bar_y_ticks: confirmFlagOn(s.bar_y_ticks),
    bar_y_tick_length_cm: String(s.bar_y_tick_length_cm ?? ""),
    bar_pathway_text_x: String(s.bar_pathway_text_x ?? ""),
    bar_pathway_text_size: String(s.bar_pathway_text_size ?? ""),
    bar_show_gene_id: confirmFlagOn(s.bar_show_gene_id),
    bar_gene_show_n: String(s.bar_gene_show_n ?? ""),
    bar_gene_text_x: String(s.bar_gene_text_x ?? ""),
    bar_gene_text_vjust: String(s.bar_gene_text_vjust ?? ""),
    bar_gene_text_size: String(s.bar_gene_text_size ?? ""),
    bar_custom_gene_ids_json: String(s.bar_custom_gene_ids_json ?? "").trim(),
    bubble_size_min: String(s.bubble_size_min ?? ""),
    bubble_size_max: String(s.bubble_size_max ?? ""),
    bubble_breaks_custom: s.bubble_breaks_custom ?? "",
    legend_position: s.legend_position ?? "right",
    legend_color_title: String(s.legend_color_title ?? "").trim(),
    legend_color_title_size: String(s.legend_color_title_size ?? ""),
    legend_size_title: String(s.legend_size_title ?? "").trim(),
    legend_size_title_size: String(s.legend_size_title_size ?? ""),
    colorbar_barwidth_mm: String(s.colorbar_barwidth_mm ?? ""),
    title_size: String(s.title_size ?? ""),
    axis_x_title_size: String(s.axis_x_title_size ?? ""),
    axis_y_title_size: String(s.axis_y_title_size ?? ""),
    axis_x_text_size: String(s.axis_x_text_size ?? ""),
    axis_y_text_size: String(s.axis_y_text_size ?? ""),
    plot_title_bold: confirmFlagOn(s.plot_title_bold),
    axis_x_title_bold: confirmFlagOn(s.axis_x_title_bold),
    axis_y_title_bold: confirmFlagOn(s.axis_y_title_bold),
    axis_x_text_bold: confirmFlagOn(s.axis_x_text_bold),
    axis_y_text_bold: confirmFlagOn(s.axis_y_text_bold),
    bar_pathway_text_bold: confirmFlagOn(s.bar_pathway_text_bold),
    y_wrap_width: String(s.y_wrap_width ?? ""),
    axis_y_text_lineheight: String(s.axis_y_text_lineheight ?? ""),
    plot_width_cm: String(s.plot_width_cm ?? "").trim(),
    plot_height_cm: String(s.plot_height_cm ?? "").trim(),
    dpi: String(s.dpi ?? ""),
    highlight_enabled: confirmFlagOn(s.highlight_terms_enabled),
    highlight_terms: String(s.highlight_terms ?? "").trim()
  };
}

/** 绘图确认 / 参数预览：统一可读行（含稳定 id 供 diff） */
function buildPlotConfirmDisplayList(bag, opts) {
  const { row, isBar, isZh } = opts;
  const emptyLbl = confirmEmptyLabel(isZh);
  const nz = (v) => confirmNz(v, emptyLbl);
  const onOff = (on) => (on ? row.showGridOn : row.showGridOff);
  const rows = [];
  const push = (id, key, value) => rows.push({ id, key, value: String(value) });

  push(
    "file",
    row.plotConfirmFile,
    bag.input_file?.trim() ? bag.input_file : row.noFileSelected
  );
  push("genome", row.plotConfirmGenome, nz(bag.genome));
  push("enrichment", row.plotConfirmEnrichment, nz(bag.enrichment_type));
  push("topN", row.plotConfirmTopN, nz(bag.top_pathways));
  push("sigStd", row.plotConfirmSigStd, nz(bag.arrange_standard));
  push("xAxis", row.plotConfirmXAxis, nz(bag.x_axis));
  push("sort", row.plotConfirmSort, nz(bag.arrange_way));

  if (!isBar) {
    push("showGrid", row.showGrid, onOff(bag.show_grid));
    if (bag.show_grid) {
      push(
        "gridStyle",
        row.gridLinesStyle,
        `${row.gridLinesMajor}: ${nz(bag.grid_major_color)} / ${nz(bag.grid_major_linewidth)}；${row.gridLinesMinor}: ${nz(bag.grid_minor_color)} / ${nz(bag.grid_minor_linewidth)}`
      );
    }
  }

  push("colorLow", row.colorLow, nz(bag.color_low));
  push("colorHigh", row.colorHigh, nz(bag.color_high));
  push("plotTitle", row.plotTitle, nz(bag.plot_title));
  push("xTitle", row.xTitle, nz(bag.x_axis_title));
  push("yTitle", row.yTitle, nz(bag.y_axis_title));

  if (isBar) {
    push("barWidth", row.barWidth, nz(bag.bar_width));
    push("barAlpha", row.barAlpha, nz(bag.bar_alpha));
    push("barXExpandLeft", row.barXExpandLeft, nz(bag.bar_x_expand_left));
    push("barXExpandRight", row.barXExpandRight, nz(bag.bar_x_expand_right));
    push("barYTicks", row.barYTicks, onOff(bag.bar_y_ticks));
    push("barYTickLengthCm", row.barYTickLengthCm, nz(bag.bar_y_tick_length_cm));
    push("barPathwayTextX", row.barPathwayTextX, nz(bag.bar_pathway_text_x));
    push("barPathwayTextSize", row.barPathwayTextSize, nz(bag.bar_pathway_text_size));
    push("barShowGeneId", row.barShowGeneId, onOff(bag.bar_show_gene_id));
    if (bag.bar_show_gene_id) {
      push("barGeneShowN", row.barGeneShowN, nz(bag.bar_gene_show_n));
      push("barGeneTextX", row.barGeneTextX, nz(bag.bar_gene_text_x));
      push("barGeneTextVjust", row.barGeneTextVjust, nz(bag.bar_gene_text_vjust));
      push("barGeneTextSize", row.barGeneTextSize, nz(bag.bar_gene_text_size));
      push(
        "barCustomGeneIds",
        row.plotConfirmBarCustomGeneIds,
        formatBarCustomGeneIdsConfirmValue(row, bag, isZh)
      );
    }
  } else {
    push("bubbleSize", row.plotConfirmSizeRange, `${nz(bag.bubble_size_min)} ~ ${nz(bag.bubble_size_max)}`);
    push(
      "bubbleBreaks",
      row.bubbleBreaks,
      String(bag.bubble_breaks_custom || "").trim() ? String(bag.bubble_breaks_custom) : row.auto
    );
  }

  push("legendPos", row.paramLegendPosition, nz(bag.legend_position));
  push(
    "legendColorTitle",
    row.legendColorTitleLabel,
    bag.legend_color_title || row.legendColorTitleDefaultShort
  );
  push("legendColorTitleSize", row.legendColorTitleSizeLabel, nz(bag.legend_color_title_size));
  if (!isBar) {
    push(
      "legendSizeTitle",
      row.legendSizeTitleLabel,
      bag.legend_size_title || row.legendSizeTitleDefaultShort
    );
    push("legendSizeTitleSize", row.legendSizeTitleSizeLabel, nz(bag.legend_size_title_size));
  }
  push("colorbarWidth", row.paramColorbarBarwidthMm, nz(bag.colorbar_barwidth_mm));
  push("titleSize", row.plotTitleStyle, nz(bag.title_size));
  push("axisXTitleSize", row.paramAxisXTitleSize, nz(bag.axis_x_title_size));
  push("axisYTitleSize", row.paramAxisYTitleSize, nz(bag.axis_y_title_size));
  push("axisXText", row.axisXText, nz(bag.axis_x_text_size));
  if (!isBar) {
    push("axisYText", row.axisYText, nz(bag.axis_y_text_size));
    push("yWrap", row.pathwayWrapWidth, nz(bag.y_wrap_width));
    push("yLineheight", row.axisYLineheightLabel, nz(bag.axis_y_text_lineheight));
  }
  push("axisBold", row.axisBoldMenuTitle, formatAxisBoldConfirmValue(row, bag, isZh));
  const wcm = String(bag.plot_width_cm ?? "").trim();
  const hcm = String(bag.plot_height_cm ?? "").trim();
  const dpiStr = String(bag.dpi ?? "").trim();
  const canvasParts = [`${wcm || row.auto} × ${hcm || row.auto} cm`];
  if (dpiStr) canvasParts.push(`${dpiStr} DPI`);
  push("canvas", row.plotConfirmCanvas, canvasParts.join(" @ "));
  if (!isBar) {
    push("highlight", row.plotConfirmHighlight, formatHighlightConfirmValue(row, bag, isZh));
  }
  return rows;
}

/** 预览「作图参数」：与界面标签一致的可读列表（来自最近一次请求快照） */
const lastPlotParamsDisplayRows = computed(() => {
  const s = lastPlotParamsSnapshot.value;
  if (!s || typeof s !== "object") return [];
  const isZh = lang.value === "zh";
  const isBar = String(s.plot_type || "").toLowerCase() === "bar";
  return buildPlotConfirmDisplayList(snapshotToConfirmBag(s), {
    row: t.value,
    isBar,
    isZh
  }).map(({ key, value }) => ({ key, value }));
});

/** 收集作图表单全部响应式依赖，确保确认弹窗在多次改参后仍会重新 diff */
function collectPlotConfirmReactiveDeps() {
  void activeTab.value;
  void fileLabel.value;
  void isBarTool.value;
  void lang.value;
  void lastPlotParamsSnapshot.value;
  void plotConfirmOpenSeq.value;
  void highlightedPathways.value.join("\n");
  void JSON.stringify(barPathwayCustomGeneIds.value);
  for (const key of Object.keys(form)) {
    void form[key];
  }
}

const plotConfirmItemsWithDiff = computed(() => {
  collectPlotConfirmReactiveDeps();
  const isZh = lang.value === "zh";
  const row = t.value;
  const isBar = isBarTool.value;
  const curApi = getPlotParamsForConfirmCompare();
  const prevSnap = lastPlotParamsSnapshot.value;
  const currentBag = snapshotToConfirmBag(curApi);
  const current = buildPlotConfirmDisplayList(currentBag, { row, isBar, isZh });
  if (!prevSnap) {
    return current.map((r) => ({ ...r, changed: false }));
  }
  const previous = buildPlotConfirmDisplayList(snapshotToConfirmBag(prevSnap), {
    row,
    isBar: String(prevSnap.plot_type || "").toLowerCase() === "bar",
    isZh
  });
  const prevById = Object.fromEntries(previous.map((r) => [r.id, r.value]));
  const unsetLbl = isZh ? "（未设置）" : "(not set)";
  return current.map((r) => {
    const changed = isConfirmRowChanged(r.id, curApi, prevSnap);
    const oldValue = prevById[r.id] ?? unsetLbl;
    return { ...r, changed, oldValue: changed ? oldValue : undefined };
  });
});

const plotConfirmChangedItems = computed(() =>
  plotConfirmItemsWithDiff.value.filter((item) => item.changed)
);

/** 预览区标题旁：本次成功作图对应的富集来源（KEGG / GO / BP / CC / MF） */
const previewSourceLabel = computed(() => {
  if (!imageSrc.value) return "";
  let raw = statsMeta.value?.enrichment_type ?? form.enrichment_type;
  if (Array.isArray(raw) && raw.length === 1) raw = raw[0];
  if (raw == null || raw === "") return "";
  const u = String(raw).trim().toUpperCase();
  if (u === "KEGG" || u === "GO" || u === "BP" || u === "CC" || u === "MF") {
    return u;
  }
  return String(raw).trim();
});

const statsKpiLabels = computed(() => {
  const row = i18n[lang.value] || i18n.zh;
  return [row.statsKpi1, row.statsKpi2, row.statsKpi3];
});

watch(statsPageMode, (m) => {
  if (m === "custom") {
    const n = Math.min(500, Math.max(1, Number(statsCustomPageSize.value) || 1));
    statsCustomPageSize.value = n;
    statsUiPageSize.value = n;
  } else {
    statsUiPageSize.value = Math.min(500, Math.max(1, Number(m) || 10));
  }
  statsCurrentPage.value = 1;
});

watch(statsCustomPageSize, () => {
  if (statsPageMode.value !== "custom") return;
  const n = Math.min(500, Math.max(1, Number(statsCustomPageSize.value) || 1));
  statsCustomPageSize.value = n;
  statsUiPageSize.value = n;
  statsCurrentPage.value = 1;
});

const statsUiPageSizeNum = computed(() => Math.min(500, Math.max(1, Number(statsUiPageSize.value) || 10)));

/** 与 backend prepare_core 一致：统计表与通路详情弹窗优先展示这些列 */
const CORE_ENRICH_COL_ORDER = [
  "Description",
  "Count",
  "qvalue",
  "GeneRatio",
  "RichFactor",
  "pvalue",
  "category",
  "subcategory",
  "geneID",
  "negLog10_pvalue",
  "negLog10_qvalue"
];

function orderEnrichmentKeys(keys) {
  const set = new Set(keys);
  const head = CORE_ENRICH_COL_ORDER.filter((k) => set.has(k));
  const tail = keys
    .filter((k) => !CORE_ENRICH_COL_ORDER.includes(k))
    .sort((a, b) => a.localeCompare(b));
  return [...head, ...tail];
}

const statsTableColumnKeys = computed(() => {
  const row0 = statsDisplayRows.value[0];
  if (!row0 || typeof row0 !== "object") return [];
  return orderEnrichmentKeys(Object.keys(row0));
});

function statsCellValue(v) {
  if (v === null || v === undefined) return "";
  if (typeof v === "number" && Number.isFinite(v)) return v;
  const s = String(v).trim();
  if (s === "") return "";
  const n = Number(s);
  if (Number.isFinite(n) && /^-?\d/.test(s)) return n;
  return s;
}

const statsRowsSorted = computed(() => {
  const rows = statsDisplayRows.value.map((r) => ({ ...r }));
  const prop = statsSortProp.value;
  const order = statsSortOrder.value;
  if (!prop || !order) return rows;
  rows.sort((a, b) => {
    const av = statsCellValue(a[prop]);
    const bv = statsCellValue(b[prop]);
    let cmp = 0;
    if (typeof av === "number" && typeof bv === "number") {
      cmp = av - bv;
    } else {
      cmp = String(av).localeCompare(String(bv), undefined, { numeric: true, sensitivity: "base" });
    }
    return order === "ascending" ? cmp : -cmp;
  });
  return rows;
});

const statsPagedRows = computed(() => {
  const size = statsUiPageSizeNum.value;
  const start = (statsCurrentPage.value - 1) * size;
  return statsRowsSorted.value.slice(start, start + size);
});

const statsKpiNumbers = computed(() => {
  const m = statsMeta.value;
  return [
    m && m.raw_n != null ? String(m.raw_n) : "—",
    m && m.display_n != null ? String(m.display_n) : statsDisplayRows.value.length ? String(statsDisplayRows.value.length) : "—",
    m && m.input_genes != null ? String(m.input_genes) : "—"
  ];
});

const statsRowsTotalLabel = computed(() => {
  const tpl = (i18n[lang.value] || i18n.zh).statsRowsTotal;
  return tpl.replace("{n}", String(statsRowsSorted.value.length));
});

function setStatsCurrentPage(p) {
  statsCurrentPage.value = p;
}

watch(
  () => statsRowsSorted.value.length,
  () => {
    const maxPage = Math.max(1, Math.ceil(statsRowsSorted.value.length / statsUiPageSizeNum.value) || 1);
    if (statsCurrentPage.value > maxPage) {
      statsCurrentPage.value = maxPage;
    }
  }
);

function clampTopPathwaysVal(raw) {
  const n = parseInt(String(raw).trim(), 10);
  if (Number.isNaN(n)) return null;
  return Math.min(100, Math.max(5, n));
}

/** 下拉预设 10/20/30 + 可输入自定义整数（与后端一致限制 5–100） */
const topPathwaysSelect = computed({
  get() {
    return form.top_pathways;
  },
  set(val) {
    if (val === null || val === undefined) return;
    const s = String(val).trim();
    if (s === "") return;
    const clamped = clampTopPathwaysVal(s);
    if (clamped === null) {
      ElMessage.warning(
        lang.value === "zh" ? "请输入 5–100 之间的整数" : "Enter an integer between 5 and 100"
      );
      return;
    }
    form.top_pathways = clamped;
  }
});

function clampByte(n) {
  return Math.max(0, Math.min(255, Math.round(Number(n) || 0)));
}

/** 将 rgb()/rgba() 转为 #rrggbb；无法解析时返回 null */
function rgbStringToHex(s) {
  const m = String(s)
    .trim()
    .match(/^rgba?\s*\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)/i);
  if (!m) return null;
  const r = clampByte(m[1]);
  const g = clampByte(m[2]);
  const b = clampByte(m[3]);
  return `#${r.toString(16).padStart(2, "0")}${g.toString(16).padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
}

/**
 * 将完整 #RGB / #RRGGBB / #RRGGBBAA 或 rgb()/rgba() 转为 #rrggbb；否则返回 null。
 * 注意：#RGB 三位的展开仅适合在 finalizePlotColor（提交作图）时调用，输入过程中用会误伤退格中间态（如 #e0e0e0 → #eee）。
 */
function tryNormalizeColorToHex(s) {
  const t = typeof s === "string" ? s.trim() : "";
  if (!t) return null;
  if (/^#[0-9a-fA-F]{8}$/i.test(t)) return t.slice(0, 7).toLowerCase();
  if (/^#[0-9a-fA-F]{6}$/i.test(t)) return t.toLowerCase();
  if (/^#[0-9a-fA-F]{3}$/i.test(t)) {
    const x = t.slice(1);
    return `#${x[0]}${x[0]}${x[1]}${x[1]}${x[2]}${x[2]}`.toLowerCase();
  }
  return rgbStringToHex(t);
}

/** 提交作图前尽量规范为十六进制；无法识别时保留原串，由 R 端 normalize_color_hex 兜底 */
function finalizePlotColor(s, fallback) {
  const base = typeof s === "string" && s.trim() ? s.trim() : fallback;
  const n = tryNormalizeColorToHex(base);
  return n !== null ? n : base;
}

/**
 * el-color-picker 的 modelValue 须为 string；若为数组会与 EP 内部 mergeProps 冲突。
 * 允许空串 / null：用户可在文本框中先删光再输入；提交作图时由 finalizePlotColor 再兜底。
 */
function coerceColorModel(v, fallback) {
  if (Array.isArray(v)) {
    const x = v[0];
    return typeof x === "string" && x.length ? x : fallback;
  }
  if (typeof v === "string") {
    return v;
  }
  if (v == null) {
    return "";
  }
  return fallback;
}

watch(activeTab, (v) => {
  if (v === "kegg") form.enrichment_type = "KEGG";
  else form.enrichment_type = "GO";
});

/**
 * 仅纠正取色器偶发的非 string（避免 mergeProps → setAttribute('0')）。
 * 不在此处 tryNormalizeColorToHex：退格中间态如 #eee 会被当成 3 位简写展开为 #eeeeee，与正在编辑的 #e0e0e0 冲突。
 * 规范化在点击生成图表时由 finalizePlotColor 统一处理。
 */
watch(
  () => [form.color_low, form.color_high],
  ([low, high]) => {
    const nl = coerceColorModel(low, "#487dad");
    const nh = coerceColorModel(high, "#bb9cc4");
    if (nl !== low) form.color_low = nl;
    if (nh !== high) form.color_high = nh;
  },
  { deep: true, flush: "post" }
);

watch(
  () => [form.grid_major_color, form.grid_minor_color],
  ([maj, minc]) => {
    const nm = coerceColorModel(maj, "#d3d3d3");
    const nn = coerceColorModel(minc, "#e0e0e0");
    if (nm !== maj) form.grid_major_color = nm;
    if (nn !== minc) form.grid_minor_color = nn;
  },
  { deep: true, flush: "post" }
);

function exampleLabel(ex) {
  return lang.value === "zh" ? ex.label_zh : ex.label_en;
}

async function loadExampleFile(filePath) {
  const name = filePath.split("/").pop() || "example.csv";
  try {
    const res = await fetch(filePath);
    if (!res.ok) throw new Error(String(res.status));
    const blob = await res.blob();
    const lower = name.toLowerCase();
    let mime = blob.type || "application/octet-stream";
    if (lower.endsWith(".csv")) mime = "text/csv";
    else if (lower.endsWith(".tsv")) mime = "text/tab-separated-values";
    else if (lower.endsWith(".xlsx")) mime = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    else if (lower.endsWith(".xls")) mime = "application/vnd.ms-excel";
    rawFile.value = new File([blob], name, { type: mime });
    fileLabel.value = name;
    syncActiveToolStateToStore();
    ElMessage.success(lang.value === "zh" ? `已加载示例：${name}` : `Loaded: ${name}`);
  } catch {
    ElMessage.error(lang.value === "zh" ? "示例文件读取失败" : "Failed to load sample file");
  }
}

/** 加载当前工具对应的第一项示例（运行示例等复用） */
async function loadExample() {
  const first = toolExampleFiles.value[0];
  if (first?.file) {
    await loadExampleFile(first.file);
  }
}

onMounted(async () => {
  try {
    const res = await fetch("/examples/manifest.json");
    if (!res.ok) return;
    const list = await res.json();
    if (!Array.isArray(list) || list.length === 0) return;
    const mapped = list
      .filter((x) => x && typeof x.file === "string" && x.file.length > 0)
      .map((x) => {
        const base = x.file.split("/").pop() || x.file;
        return {
          file: x.file,
          label_zh: x.label_zh || base,
          label_en: x.label_en || base,
          tool: x.tool || null
        };
      });
    if (mapped.length > 0) {
      exampleFiles.value = mapped;
    }
  } catch {
    /* 保持默认内置列表 */
  }
});

const PREVIEW_MAX_ROWS = 300;

function resetPreviewDialogState() {
  previewLoading.value = true;
  previewPlainText.value = "";
  previewTableColumns.value = [];
  previewTableRows.value = [];
  previewTruncatedNote.value = "";
}

function normalizePreviewHeaderNames(rawHeader) {
  const seen = {};
  return rawHeader.map((name, i) => {
    let base = name == null || String(name).trim() === "" ? `Column${i + 1}` : String(name).trim();
    if (seen[base]) {
      seen[base] += 1;
      base = `${base}_${seen[base]}`;
    } else {
      seen[base] = 1;
    }
    return base;
  });
}

function tablePreviewFromAoA(aoa) {
  if (!Array.isArray(aoa) || aoa.length === 0) {
    return { columns: [], rows: [], truncated: false };
  }
  const header = normalizePreviewHeaderNames(aoa[0]);
  const rows = [];
  const dataRowCount = aoa.length - 1;
  const limit = Math.min(dataRowCount, PREVIEW_MAX_ROWS);
  for (let i = 1; i <= limit; i++) {
    const line = aoa[i] || [];
    const row = {};
    header.forEach((col, j) => {
      const cell = line[j];
      row[col] = cell == null ? "" : String(cell);
    });
    rows.push(row);
  }
  return {
    columns: header,
    rows,
    truncated: dataRowCount > PREVIEW_MAX_ROWS
  };
}

function setPreviewTableFromAoA(aoa) {
  const { columns, rows, truncated } = tablePreviewFromAoA(aoa);
  previewTableColumns.value = columns;
  previewTableRows.value = rows;
  previewTruncatedNote.value = truncated
    ? lang.value === "zh"
      ? `（预览已截断，仅显示前 ${PREVIEW_MAX_ROWS} 行）`
      : `(Preview truncated: first ${PREVIEW_MAX_ROWS} rows)`
    : "";
}

async function openPreview() {
  if (!rawFile.value) {
    ElMessage.warning(lang.value === "zh" ? "请先选择文件" : "Pick a file first");
    return;
  }
  const f = rawFile.value;
  const name = f.name.toLowerCase();
  const zh = lang.value === "zh";

  resetPreviewDialogState();
  previewVisible.value = true;

  try {
    if (name.endsWith(".csv") || name.endsWith(".tsv") || name.endsWith(".txt")) {
      const text = await f.text();
      const { read, utils } = await import("xlsx");
      const readOpts = { type: "string" };
      if (name.endsWith(".tsv")) {
        readOpts.FS = "\t";
      }
      const wb = read(text, readOpts);
      const sheet0 = wb.SheetNames && wb.SheetNames[0];
      if (!sheet0) {
        previewPlainText.value = zh ? "无法预览：文件中没有可解析的数据。" : "Cannot preview: no parseable data.";
        return;
      }
      const aoa = utils.sheet_to_json(wb.Sheets[sheet0], { header: 1, defval: "" });
      if (!aoa.length) {
        previewPlainText.value = zh ? "无法预览：文件为空。" : "Cannot preview: file is empty.";
        return;
      }
      setPreviewTableFromAoA(aoa);
    } else if (name.endsWith(".xlsx") || name.endsWith(".xls")) {
      const { read, utils } = await import("xlsx");
      const buf = await f.arrayBuffer();
      const wb = read(buf, { type: "array" });
      const sheet0 = wb.SheetNames && wb.SheetNames[0];
      if (!sheet0) {
        previewPlainText.value = zh ? "无法预览：工作簿中没有工作表。" : "Cannot preview: workbook has no sheets.";
        return;
      }
      const ws = wb.Sheets[sheet0];
      const aoa = utils.sheet_to_json(ws, { header: 1, defval: "" });
      if (!aoa.length) {
        previewPlainText.value = zh ? "无法预览：工作表为空。" : "Cannot preview: sheet is empty.";
        return;
      }
      setPreviewTableFromAoA(aoa);
    } else if (name.endsWith(".rds")) {
      previewPlainText.value = zh
        ? ".rds 为 R 二进制格式，无法在浏览器中文本预览；请用 R 读取。"
        : ".rds is an R binary format and cannot be previewed as text; open it in R.";
    } else {
      previewPlainText.value = zh
        ? "当前格式不支持文本预览；请使用 .csv / .tsv / .txt / .xlsx / .xls。"
        : "This format cannot be previewed as text; use .csv / .tsv / .txt / .xlsx / .xls.";
    }
  } catch (err) {
    const msg = err && err.message ? String(err.message) : String(err);
    previewPlainText.value = (zh ? "预览失败：" : "Preview failed: ") + msg;
    ElMessage.error(zh ? "预览失败" : "Preview failed");
  } finally {
    previewLoading.value = false;
  }
}

function barFieldsForApi(f) {
  return {
    plot_type: "bar",
    bar_width: String(f.bar_width ?? 0.45),
    bar_alpha: String(f.bar_alpha ?? 0.8),
    bar_y_ticks: f.bar_y_ticks ? "1" : "0",
    bar_y_tick_length_cm: String(f.bar_y_tick_length_cm ?? 0),
    bar_x_expand_left: String(f.bar_x_expand_left ?? 0),
    bar_x_expand_right: String(f.bar_x_expand_right ?? 0),
    bar_pathway_text_x: String(f.bar_pathway_text_x ?? 0.001),
    bar_pathway_text_size: String(f.bar_pathway_text_size ?? 4.3),
    bar_pathway_text_bold: f.bar_pathway_text_bold ? "1" : "0",
    bar_gene_text_x: String(f.bar_gene_text_x ?? 0.001),
    bar_gene_text_vjust: String(f.bar_gene_text_vjust ?? 3),
    bar_gene_text_size: String(f.bar_gene_text_size ?? 3),
    bar_show_gene_id: f.bar_show_gene_id ? "1" : "0",
    bar_gene_show_n: String(f.bar_gene_show_n ?? 10),
    bar_custom_gene_ids_json: getBarPathwayCustomGeneIdsJson()
  };
}

/** 与即将提交后端的参数一致（含颜色规范化）；用于确认弹窗 diff，不修改表单 */
function getPlotParamsForConfirmCompare() {
  if (activeTab.value === "kegg") {
    form.enrichment_type = "KEGG";
  }
  const f = form;
  const lowDefault = isBarTool.value ? "#b6abbd" : "#487dad";
  const highDefault = isBarTool.value ? "#624c74" : "#bb9cc4";
  const params = buildPlotParamsApiObject(f);
  params.color_low = finalizePlotColor(f.color_low, lowDefault);
  params.color_high = finalizePlotColor(f.color_high, highDefault);
  if (!isBarTool.value) {
    params.grid_major_color = finalizePlotColor(f.grid_major_color, "#d3d3d3");
    params.grid_minor_color = finalizePlotColor(f.grid_minor_color, "#e0e0e0");
  }
  return {
    input_file: fileLabel.value || rawFile.value?.name || "",
    ...params
  };
}

/** 提交作图前：等待控件写回、同步 KEGG 页签，并规范化颜色写入表单 */
async function prepareFormForPlotRequest() {
  await nextTick();
  if (activeTab.value === "kegg") {
    form.enrichment_type = "KEGG";
  }
  const lowDefault = isBarTool.value ? "#b6abbd" : "#487dad";
  const highDefault = isBarTool.value ? "#624c74" : "#bb9cc4";
  form.color_low = finalizePlotColor(form.color_low, lowDefault);
  form.color_high = finalizePlotColor(form.color_high, highDefault);
  if (!isBarTool.value) {
    form.grid_major_color = finalizePlotColor(form.grid_major_color, "#d3d3d3");
    form.grid_minor_color = finalizePlotColor(form.grid_minor_color, "#e0e0e0");
  }
  return buildPlotParamsApiObject();
}

/** 与 multipart / plot_params_json 一致，供预览区「作图参数」展示 */
function buildPlotParamsApiObject(formModel = form) {
  const f = formModel;
  return {
    genome: f.genome,
    enrichment_type: f.enrichment_type,
    top_pathways: String(f.top_pathways),
    arrange_standard: f.arrange_standard,
    x_axis: f.x_axis,
    arrange_way: f.arrange_way,
    show_grid: f.show_grid ? "1" : "0",
    grid_major_color: f.grid_major_color || "#d3d3d3",
    grid_major_linewidth: String(f.grid_major_linewidth ?? 0.4),
    grid_minor_color: f.grid_minor_color || "#e0e0e0",
    grid_minor_linewidth: String(f.grid_minor_linewidth ?? 0.35),
    color_low: f.color_low,
    color_high: f.color_high,
    plot_title: f.plot_title,
    x_axis_title: f.x_axis_title,
    y_axis_title: f.y_axis_title,
    bubble_size_min: String(f.bubble_size_min),
    bubble_size_max: String(f.bubble_size_max),
    bubble_breaks_custom: f.bubble_breaks_custom || "",
    title_size: String(f.title_size),
    plot_title_bold: f.plot_title_bold ? "1" : "0",
    axis_x_title_size: String(f.axis_x_title_size),
    axis_y_title_size: String(f.axis_y_title_size),
    axis_x_text_size: String(f.axis_x_text_size),
    axis_y_text_size: String(f.axis_y_text_size),
    axis_x_title_bold: f.axis_x_title_bold ? "1" : "0",
    axis_y_title_bold: f.axis_y_title_bold ? "1" : "0",
    axis_x_text_bold: f.axis_x_text_bold ? "1" : "0",
    axis_y_text_bold: f.axis_y_text_bold ? "1" : "0",
    y_wrap_width: String(f.y_wrap_width ?? 60),
    axis_y_text_lineheight: String(f.axis_y_text_lineheight ?? 1.12),
    legend_position: f.legend_position,
    legend_color_title: plotLegendColorTitleTrimmed(f),
    legend_color_title_size: String(f.legend_color_title_size ?? 11),
    legend_size_title: f.legend_size_title || "",
    legend_size_title_size: String(f.legend_size_title_size ?? 11),
    plot_width_cm:
      f.plot_width_cm != null && f.plot_width_cm > 0 ? String(f.plot_width_cm) : "",
    plot_height_cm:
      f.plot_height_cm != null && f.plot_height_cm > 0 ? String(f.plot_height_cm) : "",
    dpi: String(f.dpi),
    colorbar_barwidth_mm: String(f.colorbar_barwidth_mm ?? 4.5),
    highlight_terms_enabled:
      isBarTool.value ? "0" : highlightedPathways.value.length ? "1" : "0",
    highlight_terms: isBarTool.value ? "" : highlightedPathways.value.join("\n"),
    plot_type: isBarTool.value ? "bar" : "bubble",
    ...(isBarTool.value ? barFieldsForApi(f) : {})
  };
}

function capturePlotParamsSentWithRequest(params) {
  lastPlotParamsSnapshot.value = {
    input_file: fileLabel.value || rawFile.value?.name || "",
    ...params
  };
}

/** 将完整作图参数写入 FormData（与 plot_params_json 同源，避免字段遗漏） */
function appendPlotParamsToFormData(fd, params) {
  for (const [key, val] of Object.entries(params)) {
    if (val === undefined || val === null) continue;
    fd.append(key, String(val));
  }
  fd.append("plot_params_json", JSON.stringify(params));
}

function clearStatsResults() {
  statsRawCsv.value = "";
  statsDisplayCsv.value = "";
  statsDisplayRows.value = [];
  statsRawRows.value = [];
  statsMeta.value = null;
  statsPageMode.value = "10";
  statsCustomPageSize.value = 10;
  statsUiPageSize.value = 10;
  statsCurrentPage.value = 1;
  statsSortProp.value = "";
  statsSortOrder.value = "";
}

function revokePlotBlobUrls(state) {
  if (!state) return;
  if (state.plotObjectUrl) {
    URL.revokeObjectURL(state.plotObjectUrl);
    state.plotObjectUrl = null;
  }
  if (state.plotPdfObjectUrl) {
    URL.revokeObjectURL(state.plotPdfObjectUrl);
    state.plotPdfObjectUrl = null;
  }
  state.imageSrc = "";
}

/** 气泡图 / 条形图：各自独立、持久化的子工具工作区 */
const toolStateStore = {
  bubble: null,
  bar: null
};

function createEmptyToolSnapshot(tool) {
  return {
    form: structuredClone(buildBubbleFormDefaults()),
    activeTab: "kegg",
    loading: false,
    imageSrc: "",
    plotObjectUrl: null,
    plotPdfObjectUrl: null,
    fileLabel: "",
    rawFile: null,
    statsRawCsv: "",
    statsDisplayCsv: "",
    statsDisplayRows: [],
    statsRawRows: [],
    statsMeta: null,
    statsPageMode: "10",
    statsCustomPageSize: 10,
    statsUiPageSize: 10,
    statsCurrentPage: 1,
    statsSortProp: "",
    statsSortOrder: "",
    highlightedPathways: [],
    selectedPathwayDescription: "",
    lastPlotParamsSnapshot: null,
    barPathwayCustomGeneIds: {},
    styleSubTab: "style",
    gridStyleExpanded: false,
    bubbleStyleSections: { ...createDefaultBubbleStyleSections() },
    axisBoldSettingsExpanded: false,
    previewVisible: false,
    previewLoading: false,
    previewPlainText: "",
    previewTableColumns: [],
    previewTableRows: [],
    previewTruncatedNote: ""
  };
}

function initToolStateStores() {
  toolStateStore.bubble = createEmptyToolSnapshot("bubble");
  toolStateStore.bubble.form = structuredClone(buildBubbleFormDefaults());
  toolStateStore.bar = createEmptyToolSnapshot("bar");
  toolStateStore.bar.form = structuredClone(buildBarFormDefaults());
}

function snapshotActiveToolState() {
  return {
    form: structuredClone(toRaw(form)),
    activeTab: activeTab.value,
    loading: loading.value,
    imageSrc: imageSrc.value,
    plotObjectUrl: plotObjectUrl.value,
    plotPdfObjectUrl: plotPdfObjectUrl.value,
    fileLabel: fileLabel.value,
    rawFile: rawFile.value,
    statsRawCsv: statsRawCsv.value,
    statsDisplayCsv: statsDisplayCsv.value,
    statsDisplayRows: statsDisplayRows.value.map((r) => ({ ...r })),
    statsRawRows: statsRawRows.value.map((r) => ({ ...r })),
    statsMeta: statsMeta.value ? { ...statsMeta.value } : null,
    statsPageMode: statsPageMode.value,
    statsCustomPageSize: statsCustomPageSize.value,
    statsUiPageSize: statsUiPageSize.value,
    statsCurrentPage: statsCurrentPage.value,
    statsSortProp: statsSortProp.value,
    statsSortOrder: statsSortOrder.value,
    highlightedPathways: [...highlightedPathways.value],
    selectedPathwayDescription: selectedPathwayDescription.value,
    lastPlotParamsSnapshot: lastPlotParamsSnapshot.value
      ? { ...lastPlotParamsSnapshot.value }
      : null,
    barPathwayCustomGeneIds: { ...barPathwayCustomGeneIds.value },
    styleSubTab: styleSubTab.value,
    gridStyleExpanded: gridStyleExpanded.value,
    bubbleStyleSections: { ...bubbleStyleSections },
    axisBoldSettingsExpanded: axisBoldSettingsExpanded.value,
    previewVisible: previewVisible.value,
    previewLoading: previewLoading.value,
    previewPlainText: previewPlainText.value,
    previewTableColumns: [...previewTableColumns.value],
    previewTableRows: previewTableRows.value.map((r) => ({ ...r })),
    previewTruncatedNote: previewTruncatedNote.value
  };
}

function syncActiveToolStateToStore() {
  const tool = activeAnalysisTool.value;
  if (!tool) return;
  const prev = toolStateStore[tool];
  const next = snapshotActiveToolState();
  if (prev) {
    if (prev.plotObjectUrl && prev.plotObjectUrl !== next.plotObjectUrl) {
      URL.revokeObjectURL(prev.plotObjectUrl);
    }
    if (prev.plotPdfObjectUrl && prev.plotPdfObjectUrl !== next.plotPdfObjectUrl) {
      URL.revokeObjectURL(prev.plotPdfObjectUrl);
    }
  }
  toolStateStore[tool] = next;
}

function applySnapshotToRefs(snapshot) {
  if (!snapshot) return;
  Object.assign(form, snapshot.form);
  activeTab.value = snapshot.activeTab;
  loading.value = snapshot.loading;
  imageSrc.value = snapshot.imageSrc;
  plotObjectUrl.value = snapshot.plotObjectUrl;
  plotPdfObjectUrl.value = snapshot.plotPdfObjectUrl;
  fileLabel.value = snapshot.fileLabel;
  rawFile.value = snapshot.rawFile;
  statsRawCsv.value = snapshot.statsRawCsv;
  statsDisplayCsv.value = snapshot.statsDisplayCsv;
  statsDisplayRows.value = snapshot.statsDisplayRows.map((r) => ({ ...r }));
  statsRawRows.value = snapshot.statsRawRows.map((r) => ({ ...r }));
  statsMeta.value = snapshot.statsMeta ? { ...snapshot.statsMeta } : null;
  statsPageMode.value = snapshot.statsPageMode;
  statsCustomPageSize.value = snapshot.statsCustomPageSize;
  statsUiPageSize.value = snapshot.statsUiPageSize;
  statsCurrentPage.value = snapshot.statsCurrentPage;
  statsSortProp.value = snapshot.statsSortProp;
  statsSortOrder.value = snapshot.statsSortOrder;
  highlightedPathways.value = [...snapshot.highlightedPathways];
  selectedPathwayDescription.value = snapshot.selectedPathwayDescription;
  lastPlotParamsSnapshot.value = snapshot.lastPlotParamsSnapshot
    ? { ...snapshot.lastPlotParamsSnapshot }
    : null;
  barPathwayCustomGeneIds.value = snapshot.barPathwayCustomGeneIds
    ? { ...snapshot.barPathwayCustomGeneIds }
    : {};
  styleSubTab.value = snapshot.styleSubTab;
  gridStyleExpanded.value = snapshot.gridStyleExpanded;
  if (snapshot.bubbleStyleSections) {
    Object.assign(bubbleStyleSections, createDefaultBubbleStyleSections(), snapshot.bubbleStyleSections);
  }
  axisBoldSettingsExpanded.value = snapshot.axisBoldSettingsExpanded;
  previewVisible.value = snapshot.previewVisible;
  previewLoading.value = snapshot.previewLoading;
  previewPlainText.value = snapshot.previewPlainText;
  previewTableColumns.value = [...snapshot.previewTableColumns];
  previewTableRows.value = snapshot.previewTableRows.map((r) => ({ ...r }));
  previewTruncatedNote.value = snapshot.previewTruncatedNote;
}

function openAnalysisTool(tool) {
  if (activeAnalysisTool.value === tool) return;
  syncActiveToolStateToStore();
  activeAnalysisTool.value = tool;
  applySnapshotToRefs(toolStateStore[tool]);
  if (tool === "bar") {
    highlightedPathways.value = [];
  }
}

initToolStateStores();

function releasePlotImage() {
  if (plotObjectUrl.value) {
    URL.revokeObjectURL(plotObjectUrl.value);
    plotObjectUrl.value = null;
  }
  if (plotPdfObjectUrl.value) {
    URL.revokeObjectURL(plotPdfObjectUrl.value);
    plotPdfObjectUrl.value = null;
  }
  imageSrc.value = "";
  lastPlotParamsSnapshot.value = null;
  clearStatsResults();
}

function releaseAllToolPlotResources() {
  releasePlotImage();
  revokePlotBlobUrls(toolStateStore.bubble);
  revokePlotBlobUrls(toolStateStore.bar);
  toolStateStore.bubble = null;
  toolStateStore.bar = null;
}

function onStatsSortChange({ prop, order }) {
  statsSortProp.value = prop || "";
  statsSortOrder.value = order || "";
  statsCurrentPage.value = 1;
}

function downloadTextAsCsv(text, filename) {
  const bom = "\uFEFF";
  const blob = new Blob([bom + text], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.rel = "noopener";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

function csvEscapeField(s) {
  const t = s === null || s === undefined ? "" : String(s);
  if (/[",\n\r]/.test(t)) return `"${t.replace(/"/g, '""')}"`;
  return t;
}

function rowsToCsv(rows, cols) {
  const header = cols.map(csvEscapeField).join(",");
  const lines = rows.map((row) => cols.map((c) => csvEscapeField(row[c])).join(","));
  return [header, ...lines].join("\n");
}

function downloadStatsRawCsv() {
  if (!statsRawCsv.value) {
    ElMessage.warning(lang.value === "zh" ? "请先生成图表以获取富集结果" : "Generate the plot to export raw results");
    return;
  }
  downloadTextAsCsv(statsRawCsv.value, `enrichment_raw_${Date.now()}.csv`);
}

function downloadStatsSortedCsv() {
  if (!statsDisplayRows.value.length || !statsTableColumnKeys.value.length) {
    ElMessage.warning(lang.value === "zh" ? "暂无可导出的排序结果" : "No sorted rows to export");
    return;
  }
  const cols = statsTableColumnKeys.value;
  const body = rowsToCsv(statsRowsSorted.value, cols);
  downloadTextAsCsv(body, `enrichment_sorted_view_${Date.now()}.csv`);
}

function downloadPlotPng() {
  if (!plotObjectUrl.value || !imageSrc.value) {
    ElMessage.warning(lang.value === "zh" ? "请先生成图片" : "Generate the plot first");
    return;
  }
  const a = document.createElement("a");
  a.href = plotObjectUrl.value;
  a.download = `enrichment-${isBarTool.value ? "bar" : "bubble"}-${Date.now()}.png`;
  a.rel = "noopener";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

function downloadPlotPdf() {
  if (!plotPdfObjectUrl.value) {
    return;
  }
  const a = document.createElement("a");
  a.href = plotPdfObjectUrl.value;
  a.download = `enrichment-${isBarTool.value ? "bar" : "bubble"}-${Date.now()}.pdf`;
  a.rel = "noopener";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

function pathwayTitleFor(row) {
  if (!row || row.Description == null) return "";
  return String(row.Description);
}

function pathwayHitLabel(row) {
  const d = pathwayTitleFor(row);
  const short = d.length > 96 ? `${d.slice(0, 93)}…` : d;
  return lang.value === "zh" ? `查看通路：${short}` : `Pathway: ${short}`;
}

function openSelectedPathwayDetail() {
  const desc = selectedPathwayDescription.value;
  if (!desc) {
    ElMessage.warning(lang.value === "zh" ? "请先选择一个通路" : "Please select a pathway first");
    return;
  }
  const idx = statsDisplayRows.value.findIndex((r) => String(r.Description ?? "") === desc);
  if (idx < 0) {
    ElMessage.warning(lang.value === "zh" ? "当前结果中未找到该通路" : "Pathway not found in current results");
    return;
  }
  openPathwayDetail(idx);
}

function formatPathwayDetailValue(v) {
  if (v === null || v === undefined) return "";
  if (typeof v === "object") {
    try {
      return JSON.stringify(v);
    } catch {
      return String(v);
    }
  }
  return String(v);
}

function findRawEnrichmentRow(description) {
  const rows = statsRawRows.value;
  if (!rows?.length || description === undefined || description === null) return null;
  const d = String(description);
  return rows.find((r) => String(r.Description ?? "") === d) ?? null;
}

function openPathwayDetail(index) {
  const row = statsDisplayRows.value[index];
  if (!row) return;
  const desc = row.Description != null ? String(row.Description) : "";
  pathwayDetailCurrentDescription.value = desc;
  pathwayHighlightDraft.value = highlightedPathways.value.includes(desc);
  pathwayDetailTitle.value =
    desc || (lang.value === "zh" ? "通路详情" : "Pathway details");
  const raw = findRawEnrichmentRow(desc);
  pathwayDetailIsFull.value = !!raw;
  /* 作图核心表字段（含 category/subcategory/geneID）覆盖全量表同名列，并保留全量表独有列 */
  const source = raw ? { ...raw, ...row } : { ...row };
  pathwayDetailEntries.value = orderEnrichmentKeys(Object.keys(source)).map((k) => ({
    key: k,
    value: formatPathwayDetailValue(source[k])
  }));
  syncPathwayGeneCustomDraft();
  pathwayDetailVisible.value = true;
}

function syncPathwayGeneCustomDraft() {
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) {
    pathwayGeneCustomDraft.value = "";
    return;
  }
  const custom = barPathwayCustomGeneIds.value[desc];
  pathwayGeneCustomDraft.value =
    custom && String(custom).trim() ? String(custom) : "";
}

function applyPathwayGeneCustom() {
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) return;
  const normalized = normalizeCustomBarGeneIdsText(pathwayGeneCustomDraft.value);
  if (!normalized) {
    ElMessage.warning(
      lang.value === "zh" ? "请输入至少一个基因 ID" : "Enter at least one gene ID"
    );
    return;
  }
  barPathwayCustomGeneIds.value = { ...barPathwayCustomGeneIds.value, [desc]: normalized };
  pathwayGeneCustomDraft.value = normalized;
  ElMessage.success(t.value.pathwayGeneCustomApplied);
  syncActiveToolStateToStore();
}

function clearPathwayGeneCustom() {
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) return;
  const next = { ...barPathwayCustomGeneIds.value };
  delete next[desc];
  barPathwayCustomGeneIds.value = next;
  pathwayGeneCustomDraft.value = "";
  ElMessage.success(t.value.pathwayGeneCustomCleared);
  syncActiveToolStateToStore();
}

function onPathwayHighlightToggle(v) {
  if (isBarTool.value) return;
  const desc = pathwayDetailCurrentDescription.value;
  if (!desc) return;
  const set = new Set(highlightedPathways.value);
  if (v) {
    set.add(desc);
  } else {
    set.delete(desc);
  }
  highlightedPathways.value = Array.from(set);
  pathwayDetailVisible.value = false;
}

/**
 * 将接口返回的 base64 转为 Blob URL（img 的 data: URL 过长时 Chrome/Edge 会拒绝显示，表现为裂图 + alt 文案）
 */
function setPlotFromBase64Response(data) {
  const mime = typeof data.mime === "string" && data.mime ? data.mime : "image/png";
  let b64 = data.image;
  if (Array.isArray(b64)) {
    b64 = b64.join("");
  }
  if (typeof b64 !== "string" || !b64.length) {
    throw new Error(lang.value === "zh" ? "响应中缺少图片数据" : "Missing image in response");
  }
  const clean = b64.replace(/\s+/g, "");
  const bin = atob(clean);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) {
    bytes[i] = bin.charCodeAt(i);
  }
  const blob = new Blob([bytes], { type: mime });
  if (plotObjectUrl.value) {
    URL.revokeObjectURL(plotObjectUrl.value);
  }
  plotObjectUrl.value = URL.createObjectURL(blob);
  imageSrc.value = plotObjectUrl.value;
}

function createPlotObjectUrlFromResponse(data) {
  const hasBlob = data.blob instanceof Blob && data.blob.size > 0;
  const b64raw =
    typeof data.image === "string"
      ? data.image
      : Array.isArray(data.image)
        ? data.image.join("")
        : "";
  const hasB64 = b64raw.replace(/\s+/g, "").length > 0;
  if (hasBlob) {
    return URL.createObjectURL(data.blob);
  }
  if (!hasB64) {
    return null;
  }
  const mime = typeof data.mime === "string" && data.mime ? data.mime : "image/png";
  const clean = b64raw.replace(/\s+/g, "");
  const bin = atob(clean);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) {
    bytes[i] = bin.charCodeAt(i);
  }
  return URL.createObjectURL(new Blob([bytes], { type: mime }));
}

function applyPlotResponseToToolStore(tool, data) {
  const saved = toolStateStore[tool];
  if (!saved) return false;
  const plotUrl = createPlotObjectUrlFromResponse(data);
  if (!plotUrl) return false;
  if (saved.plotObjectUrl) {
    URL.revokeObjectURL(saved.plotObjectUrl);
  }
  if (saved.plotPdfObjectUrl) {
    URL.revokeObjectURL(saved.plotPdfObjectUrl);
  }
  saved.plotObjectUrl = plotUrl;
  saved.imageSrc = plotUrl;
  saved.plotPdfObjectUrl =
    data.pdf_blob instanceof Blob && data.pdf_blob.size > 0
      ? URL.createObjectURL(data.pdf_blob)
      : null;
  saved.statsRawCsv = typeof data.raw_enrichment_csv === "string" ? data.raw_enrichment_csv : "";
  saved.statsDisplayCsv =
    typeof data.display_results_csv === "string" ? data.display_results_csv : "";
  if (Array.isArray(data.display_results)) {
    saved.statsDisplayRows = data.display_results.map((r) => ({ ...r }));
    const inPlotDescriptions = new Set(
      saved.statsDisplayRows.map((r) => String(r.Description ?? "")).filter((x) => x.length > 0)
    );
    saved.highlightedPathways = saved.highlightedPathways.filter((x) => inPlotDescriptions.has(x));
    if (!inPlotDescriptions.has(saved.selectedPathwayDescription)) {
      saved.selectedPathwayDescription = "";
    }
  } else {
    saved.statsDisplayRows = [];
    saved.highlightedPathways = [];
    saved.selectedPathwayDescription = "";
  }
  saved.statsRawRows = Array.isArray(data.raw_enrichment)
    ? data.raw_enrichment.map((r) => ({ ...r }))
    : [];
  const plotMeta = data.meta && typeof data.meta === "object" ? { ...data.meta } : null;
  saved.statsMeta = plotMeta;
  if (plotMeta) {
    const mw = Array.isArray(plotMeta.width_cm) ? plotMeta.width_cm[0] : plotMeta.width_cm;
    const mh = Array.isArray(plotMeta.height_cm) ? plotMeta.height_cm[0] : plotMeta.height_cm;
    const nw = Number(mw);
    const nh = Number(mh);
    if (Number.isFinite(nw) && nw > 0) {
      saved.form.plot_width_cm = Math.round(nw * 100) / 100;
    }
    if (Number.isFinite(nh) && nh > 0) {
      saved.form.plot_height_cm = Math.round(nh * 100) / 100;
    }
  }
  saved.statsPageMode = "10";
  saved.statsUiPageSize = 10;
  saved.statsCustomPageSize = 10;
  saved.statsCurrentPage = 1;
  saved.statsSortProp = "";
  saved.statsSortOrder = "";
  saved.loading = false;
  return true;
}

async function generate() {
  if (!rawFile.value) {
    ElMessage.error(lang.value === "zh" ? "请先选择基因文件" : "Select a gene file");
    return;
  }
  const requestingTool = activeAnalysisTool.value;
  if (!requestingTool) return;
  const plotParams = await prepareFormForPlotRequest();
  loading.value = true;
  releasePlotImage();
  syncActiveToolStateToStore();
  try {
    /* Plumber @parser multi：必须用 multipart/form-data，文件字段名固定为 file；不要手动设置 Content-Type */
    const fd = new FormData();
    /* 第三参数：显式原始文件名，避免部分环境下 multipart 缺少 filename 导致后端无法识别扩展名 */
    fd.append("file", rawFile.value, rawFile.value.name || "deg.txt");
    appendPlotParamsToFormData(fd, plotParams);
    const data = await requestBubblePlot(fd);
    const okRaw = data && data.ok;
    const businessOk =
      okRaw === true ||
      okRaw === 1 ||
      (Array.isArray(okRaw) && okRaw.length === 1 && (okRaw[0] === true || okRaw[0] === 1));
    if (!businessOk) {
      ElMessage.error((data && data.error) || "Error");
      return;
    }
    capturePlotParamsSentWithRequest(plotParams);
    if (activeAnalysisTool.value !== requestingTool) {
      if (!applyPlotResponseToToolStore(requestingTool, data)) {
        ElMessage.error(
          lang.value === "zh"
            ? "未收到图片数据。请 F12 → 网络(Network) → 选 plot 请求：状态码应为 200，类型为 png 或二进制；若为 JSON 请把响应体前 200 字复制反馈。"
            : "No image in response. Check Network → plot: status 200, type binary/PNG."
        );
        return;
      }
      await nextTick();
      ElMessage.success(lang.value === "zh" ? "绘制完成" : "Done");
      syncActiveToolStateToStore();
      return;
    }
    try {
      const hasBlob = data.blob instanceof Blob && data.blob.size > 0;
      const b64raw =
        typeof data.image === "string"
          ? data.image
          : Array.isArray(data.image)
            ? data.image.join("")
            : "";
      const hasB64 = b64raw.replace(/\s+/g, "").length > 0;

      if (hasBlob) {
        if (plotObjectUrl.value) {
          URL.revokeObjectURL(plotObjectUrl.value);
          plotObjectUrl.value = null;
        }
        plotObjectUrl.value = URL.createObjectURL(data.blob);
        imageSrc.value = plotObjectUrl.value;
      } else if (hasB64) {
        setPlotFromBase64Response({
          mime: typeof data.mime === "string" ? data.mime : "image/png",
          image: b64raw
        });
      } else {
        ElMessage.error(
          lang.value === "zh"
            ? "未收到图片数据。请 F12 → 网络(Network) → 选 plot 请求：状态码应为 200，类型为 png 或二进制；若为 JSON 请把响应体前 200 字复制反馈。"
            : "No image in response. Check Network → plot: status 200, type binary/PNG."
        );
        return;
      }

      if (data.pdf_blob instanceof Blob && data.pdf_blob.size > 0) {
        plotPdfObjectUrl.value = URL.createObjectURL(data.pdf_blob);
      } else {
        plotPdfObjectUrl.value = null;
      }

      if (typeof data.raw_enrichment_csv === "string") {
        statsRawCsv.value = data.raw_enrichment_csv;
      } else {
        statsRawCsv.value = "";
      }
      if (typeof data.display_results_csv === "string") {
        statsDisplayCsv.value = data.display_results_csv;
      } else {
        statsDisplayCsv.value = "";
      }
      if (Array.isArray(data.display_results)) {
        statsDisplayRows.value = data.display_results.map((r) => ({ ...r }));
        const inPlotDescriptions = new Set(
          statsDisplayRows.value.map((r) => String(r.Description ?? "")).filter((x) => x.length > 0)
        );
        highlightedPathways.value = highlightedPathways.value.filter((x) => inPlotDescriptions.has(x));
        if (!inPlotDescriptions.has(selectedPathwayDescription.value)) {
          selectedPathwayDescription.value = "";
        }
      } else {
        statsDisplayRows.value = [];
        highlightedPathways.value = [];
        selectedPathwayDescription.value = "";
      }
      if (Array.isArray(data.raw_enrichment)) {
        statsRawRows.value = data.raw_enrichment.map((r) => ({ ...r }));
      } else {
        statsRawRows.value = [];
      }
      const plotMeta = data.meta && typeof data.meta === "object" ? { ...data.meta } : null;
      statsMeta.value = plotMeta;
      if (plotMeta) {
        const mw = Array.isArray(plotMeta.width_cm) ? plotMeta.width_cm[0] : plotMeta.width_cm;
        const mh = Array.isArray(plotMeta.height_cm) ? plotMeta.height_cm[0] : plotMeta.height_cm;
        const nw = Number(mw);
        const nh = Number(mh);
        if (Number.isFinite(nw) && nw > 0) {
          form.plot_width_cm = Math.round(nw * 100) / 100;
        }
        if (Number.isFinite(nh) && nh > 0) {
          form.plot_height_cm = Math.round(nh * 100) / 100;
        }
      }
      statsPageMode.value = "10";
      statsUiPageSize.value = 10;
      statsCustomPageSize.value = 10;
      statsCurrentPage.value = 1;
      statsSortProp.value = "";
      statsSortOrder.value = "";
    } catch (e) {
      ElMessage.error(e?.message || (lang.value === "zh" ? "图片解码失败" : "Image decode failed"));
      return;
    }
    await nextTick();
    ElMessage.success(lang.value === "zh" ? "绘制完成" : "Done");
    syncActiveToolStateToStore();
  } catch (e) {
    ElMessage.error(e?.message || "Network error");
  } finally {
    if (activeAnalysisTool.value === requestingTool) {
      loading.value = false;
      syncActiveToolStateToStore();
    } else if (toolStateStore[requestingTool]) {
      toolStateStore[requestingTool].loading = false;
    }
  }
}

onUnmounted(() => {
  releaseAllToolPlotResources();
});

async function runExample() {
  if (isBarTool.value) {
    applyBarFormDefaults();
    barPathwayCustomGeneIds.value = {};
    highlightedPathways.value = [];
  }
  await loadExample();
  await generate();
}

async function requestGenerateWithConfirm() {
  if (loading.value) return;
  if (!rawFile.value) {
    ElMessage.error(lang.value === "zh" ? "请先选择基因文件" : "Select a gene file");
    return;
  }
  if (activeTab.value === "kegg") {
    form.enrichment_type = "KEGG";
  }
  await nextTick();
  plotConfirmOpenSeq.value += 1;
  plotConfirmVisible.value = true;
}

watch(
  () => plotConfirmVisible.value,
  (visible) => {
    if (!visible) return;
    plotConfirmOpenSeq.value += 1;
  }
);

watch(
  form,
  () => {
    if (plotConfirmVisible.value) {
      plotConfirmOpenSeq.value += 1;
    }
  },
  { deep: true }
);

watch(highlightedPathways, () => {
  if (plotConfirmVisible.value) {
    plotConfirmOpenSeq.value += 1;
  }
});

async function confirmPlotAction() {
  if (loading.value) return;
  plotConfirmVisible.value = false;
  await generate();
}
</script>

<style scoped>
.page {
  position: relative;
  isolation: isolate;
  overflow-x: clip;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(180deg, #e9f4ea 0%, #f7f5ef 45%, #f3f8f4 100%);
  padding: 0 20px 32px;
  font-family: "Segoe UI", system-ui, sans-serif;
  color: #2b2b2b;
}

/* 主内容区（90% 缩放）；顶栏 site-nav 在其外，保持全宽 */
.page-main {
  flex: 1 1 auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.page-main > .home-cover,
.page-main > .analysis-shell {
  flex: 1 1 auto;
  min-height: 0;
}

.analysis-shell {
  display: flex;
  width: 100%;
  min-height: 0;
  flex: 1 1 auto;
  max-height: 100%;
  border-radius: 10px;
  overflow: hidden;
  border: 1px solid rgba(91, 140, 122, 0.12);
  box-shadow: 0 10px 32px rgba(45, 107, 71, 0.08);
  background: #ffffff;
  position: relative;
}

.analysis-sidebar {
  flex-shrink: 0;
  width: 220px;
  background: #111827;
  color: #f9fafb;
  display: flex;
  flex-direction: column;
  padding: 22px 0 14px;
  position: relative;
  overflow: hidden;
  transition:
    width 0.28s ease,
    padding 0.28s ease,
    opacity 0.22s ease;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar {
  width: 52px;
  padding: 0;
  background: #000000;
  opacity: 1;
  pointer-events: auto;
}

.analysis-sidebar__head {
  padding: 0 44px 16px 18px;
  flex-shrink: 0;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar__body {
  display: none;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar__head {
  display: none;
}

.analysis-sidebar__body {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
  padding-right: 44px;
}

.analysis-sidebar-toggle {
  position: absolute;
  top: 50%;
  right: 10px;
  z-index: 2;
  transform: translateY(-50%);
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  color: rgba(249, 250, 251, 0.9);
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  transition:
    background 0.18s ease,
    color 0.18s ease,
    border-color 0.18s ease,
    right 0.28s ease,
    left 0.28s ease,
    transform 0.28s ease;
}

.analysis-sidebar-toggle:hover {
  background: rgba(255, 255, 255, 0.12);
  border-color: rgba(255, 255, 255, 0.28);
  color: #ffffff;
}

.analysis-sidebar-toggle__icon {
  width: 16px;
  height: 16px;
  display: block;
  transition: transform 0.28s ease;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar-toggle {
  right: auto;
  left: 50%;
  transform: translate(-50%, -50%);
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar-toggle__icon {
  transform: rotate(180deg);
}

.analysis-sidebar__title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
  width: 100%;
  padding: 0 12px 0 18px;
}

.analysis-sidebar__title-text-btn,
.analysis-sidebar__chevron-btn {
  margin: 0;
  border: none;
  background: transparent;
  color: #f9fafb;
  font-family: inherit;
  cursor: pointer;
  transition: background 0.18s ease, color 0.18s ease;
}

.analysis-sidebar__title-text-btn {
  flex: 1;
  min-width: 0;
  padding: 6px 4px;
  font-size: 1.05rem;
  font-weight: 700;
  letter-spacing: 0.02em;
  text-align: left;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  border-radius: 8px;
}

.analysis-sidebar__title-text-btn:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #ffffff;
}

.analysis-sidebar__title-text-btn:focus-visible,
.analysis-sidebar__chevron-btn:focus-visible {
  outline: 2px solid rgba(255, 255, 255, 0.45);
  outline-offset: 2px;
}

.analysis-sidebar__chevron-btn {
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  padding: 0;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.22);
  background: rgba(255, 255, 255, 0.06);
  box-sizing: border-box;
}

.analysis-sidebar__chevron-btn:hover {
  background: rgba(255, 255, 255, 0.14);
  border-color: rgba(255, 255, 255, 0.36);
  color: #ffffff;
}

.analysis-sidebar__title-chevron {
  display: block;
  width: 10px;
  height: 10px;
  border-right: 2.5px solid currentColor;
  border-bottom: 2.5px solid currentColor;
  /* 收起时朝下 ▼ */
  transform: rotate(45deg);
  margin-top: -3px;
  opacity: 0.9;
  transition: transform 0.2s ease, margin 0.2s ease;
}

/* 子菜单展开时箭头朝上 ▲ */
.analysis-sidebar__chevron-btn.is-open .analysis-sidebar__title-chevron {
  transform: rotate(-135deg);
  margin-top: 2px;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar__title-row {
  flex-direction: column;
  justify-content: center;
  padding: 0 4px;
  gap: 8px;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar__title-text-btn {
  writing-mode: vertical-rl;
  text-orientation: mixed;
  font-size: 0.82rem;
  letter-spacing: 0.1em;
  line-height: 1.35;
  max-height: 128px;
  overflow: hidden;
  text-align: center;
  padding: 4px 2px;
}

.analysis-shell.is-sidebar-collapsed .analysis-sidebar__chevron-btn {
  width: 32px;
  height: 32px;
}

.analysis-sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
}

.analysis-sidebar__item {
  display: block;
  width: 100%;
  border: none;
  background: transparent;
  color: rgba(249, 250, 251, 0.88);
  text-align: left;
  padding: 11px 18px;
  font-size: 14px;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  transition: background 0.18s ease, color 0.18s ease;
}

.analysis-sidebar__item:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #ffffff;
}

.analysis-sidebar__item.is-active {
  background: rgba(255, 255, 255, 0.14);
  color: #ffffff;
  font-weight: 600;
}

.analysis-sidebar__note {
  margin: 12px 18px 0;
  font-size: 12px;
  line-height: 1.5;
  color: rgba(249, 250, 251, 0.5);
}

.analysis-shell__main {
  flex: 1;
  min-width: 0;
  min-height: 0;
  display: flex;
  flex-direction: column;
  background: #ffffff;
  overflow: hidden;
  box-sizing: border-box;
  padding: 22px 28px 28px 32px;
}

/**
 * 侧栏展开时主区变窄：略减内边距并收窄参数控件，保持原有行数（避免 auto-fill 挤成三行）。
 */
.analysis-shell:not(.is-sidebar-collapsed) .analysis-shell__main {
  padding-left: 26px;
  padding-right: 24px;
}

.analysis-shell:not(.is-sidebar-collapsed) .file-drop-panel__actions {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 6px 8px;
  align-items: center;
}

.analysis-shell:not(.is-sidebar-collapsed) .file-drop-panel__actions :deep(.el-button) {
  width: 100%;
  padding: 8px 10px;
  font-size: 14px;
}

.analysis-shell:not(.is-sidebar-collapsed) .file-drop-panel__actions .file-status {
  grid-column: 1 / -1;
  margin-left: 0;
  max-width: 100%;
  text-align: left;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-row-4 {
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 8px 8px;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--numeric-params {
  grid-template-columns: repeat(auto-fill, minmax(7rem, 1fr));
  gap: 8px 8px;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--bubble-size-row.style-grid--numeric-params {
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr) minmax(0, 1fr);
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--params-4col,
.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--params-3col {
  gap: 8px 8px;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--params-4col {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--params-3col {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .style-grid--legend-compact-one-row {
  gap: 6px 8px;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .color-row {
  gap: 6px;
  min-width: 0;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .color-row :deep(.el-input) {
  flex: 1 1 auto;
  min-width: 0;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card :deep(.el-input-number) {
  width: 100%;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card :deep(.el-input-number .el-input__wrapper) {
  padding-left: 8px;
  padding-right: 8px;
}

.analysis-shell:not(.is-sidebar-collapsed) .style-card .field--axis-bold-entry :deep(.grid-style-expand-btn.el-button) {
  padding: 4px 8px;
  font-size: 13px;
  min-height: 30px;
}

.analysis-hub {
  flex: 1;
  padding: 10px 0 40px;
  overflow: auto;
}

.analysis-hub__header {
  max-width: 960px;
}

.analysis-hub__title {
  margin: 0;
  font-size: clamp(1.35rem, 2.4vw, 1.75rem);
  font-weight: 700;
  color: #111827;
}

.analysis-hub__divider {
  height: 1px;
  margin-top: 14px;
  background: #e5e7eb;
}

.analysis-hub__cards {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 360px));
  gap: 24px;
  margin-top: 32px;
  max-width: 100%;
  justify-content: start;
}

.analysis-hub__card {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  border: 1px solid #dbe3ea;
  border-radius: 12px;
  background: #ffffff;
  padding: 0;
  cursor: pointer;
  text-align: center;
  overflow: hidden;
  transition:
    transform 0.16s ease,
    box-shadow 0.2s ease,
    border-color 0.2s ease;
}

.analysis-hub__card:hover {
  transform: translateY(-3px);
  border-color: #93c5fd;
  box-shadow: 0 12px 28px rgba(37, 99, 235, 0.14);
}

.analysis-hub__card--soon {
  position: relative;
}

.analysis-hub__card-preview {
  display: block;
  line-height: 0;
  min-height: 210px;
  background: linear-gradient(180deg, #f8fafc 0%, #eef4fb 100%);
}

.analysis-hub__card-preview svg {
  width: 100%;
  height: auto;
  min-height: 210px;
  max-height: none;
  aspect-ratio: 16 / 10;
  display: block;
  object-fit: contain;
}

.analysis-hub__card-label {
  display: block;
  padding: 12px 14px 16px;
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
}

.analysis-hub__card-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  color: #1e3a8a;
  background: rgba(219, 234, 254, 0.95);
}

.analysis-coming-soon {
  flex: 1;
  padding: 32px 40px 48px;
  overflow: auto;
}

.analysis-coming-soon__body {
  margin-top: 28px;
  max-width: 520px;
  color: #4b5563;
  font-size: 15px;
  line-height: 1.7;
}

.analysis-coming-soon__body .el-button {
  margin-top: 20px;
}

/* 分析页：占满侧栏右侧区域，让内层 .layout 获得确定高度以拉齐左右列底 */
.analysis-shell__main > .analysis-view {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
  min-height: 0;
  width: 100%;
}

.analysis-view > .top-bar,
.analysis-view > .mode-bar {
  flex-shrink: 0;
}

.page.is-home {
  background-color: #eef6ef;
  background-image:
    radial-gradient(900px 520px at 12% 18%, rgba(111, 168, 136, 0.22), transparent 58%),
    radial-gradient(760px 520px at 88% 22%, rgba(91, 140, 122, 0.16), transparent 60%),
    radial-gradient(900px 640px at 50% 92%, rgba(255, 255, 255, 0.55), transparent 62%),
    repeating-linear-gradient(
      90deg,
      rgba(91, 140, 122, 0.05) 0px,
      rgba(91, 140, 122, 0.05) 1px,
      transparent 1px,
      transparent 44px
    ),
    repeating-linear-gradient(
      0deg,
      rgba(91, 140, 122, 0.035) 0px,
      rgba(91, 140, 122, 0.035) 1px,
      transparent 1px,
      transparent 44px
    ),
    linear-gradient(180deg, #e9f4ea 0%, #f7f5ef 45%, #f3f8f4 100%);
}

/* P1：全站顶栏导航（整体放大） */
.site-nav {
  position: sticky;
  top: 0;
  z-index: 20;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  box-sizing: border-box;
  width: 100vw;
  max-width: 100vw;
  min-height: 56px;
  padding: 16px 32px;
  margin: 0 calc(50% - 50vw) 18px;
  border-radius: 0;
  background: linear-gradient(
    145deg,
    rgba(255, 255, 255, 0.9) 0%,
    rgba(245, 252, 248, 0.78) 50%,
    rgba(255, 255, 255, 0.7) 100%
  );
  border: 1px solid rgba(91, 140, 122, 0.16);
  box-shadow:
    0 8px 28px rgba(45, 107, 71, 0.08),
    0 1px 0 rgba(255, 255, 255, 0.92) inset;
}

.site-nav__brand {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  font-size: 1.4rem;
  font-weight: 800;
  color: #2d6b47;
  letter-spacing: 0.02em;
}

.site-nav__brand-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  color: #2d6b47;
}

.site-nav__brand-icon-img {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: contain;
  border-radius: 0;
}

.site-nav__menu {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-left: auto;
}

.site-nav__lang-wrap {
  display: flex;
  align-items: center;
  gap: 14px;
  flex-shrink: 0;
  margin-left: 4px;
}

.site-nav__lang-divider {
  width: 1px;
  height: 36px;
  background: linear-gradient(
    180deg,
    rgba(91, 140, 122, 0.05) 0%,
    rgba(91, 140, 122, 0.32) 50%,
    rgba(91, 140, 122, 0.05) 100%
  );
  flex-shrink: 0;
}

.site-nav__lang.lang-slide {
  flex-shrink: 0;
}

.site-nav__item {
  border: 1px solid rgba(91, 140, 122, 0.2);
  background: rgba(255, 255, 255, 0.7);
  color: #4a5f55;
  border-radius: 999px;
  padding: 10px 20px;
  font-size: 15px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  transition:
    transform 0.14s ease,
    box-shadow 0.18s ease,
    border-color 0.22s ease,
    color 0.22s ease,
    background 0.22s ease;
}

.site-nav__item:hover {
  color: #2b4b3a;
  border-color: rgba(91, 140, 122, 0.36);
}

.site-nav__item.is-active {
  color: #0f4d2f;
  border-color: rgba(91, 140, 122, 0.48);
  background: linear-gradient(180deg, #ffffff 0%, #eff7f2 100%);
  box-shadow: 0 2px 8px rgba(45, 107, 71, 0.12);
}

.site-nav__item:active {
  transform: translateY(-2px);
  border-color: rgba(91, 140, 122, 0.46);
  box-shadow: 0 8px 18px rgba(45, 107, 71, 0.16);
}

.home-cover {
  display: grid;
  place-items: center;
  min-height: calc(100vh - 180px);
}

.home-cover__card {
  width: min(860px, 100%);
  text-align: center;
  padding: clamp(12px, 3vw, 28px) clamp(16px, 4vw, 24px);
  border-radius: 0;
  border: none;
  background: transparent;
  box-shadow: none;
}

.home-cover__title {
  margin: 0 0 clamp(10px, 2vw, 18px);
  font-size: clamp(2.1rem, 6.2vw, 4rem);
  line-height: 1.1;
  letter-spacing: -0.04em;
  color: #145a38;
  text-shadow: 0 1px 0 rgba(255, 255, 255, 0.9);
}

.home-cover__statement {
  margin: clamp(26px, 4vw, 40px) auto 0;
  max-width: 700px;
  color: #4d5e55;
  font-size: clamp(1rem, 2vw, 1.22rem);
  line-height: 1.7;
}

.home-cover__actions {
  margin-top: clamp(32px, 5vw, 52px);
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 18px;
}

.home-cover__btn {
  min-width: 220px;
  height: 46px;
  border-radius: 999px;
  font-size: 15px;
  font-weight: 700;
  transition:
    transform 0.14s ease,
    box-shadow 0.18s ease,
    filter 0.18s ease,
    border-color 0.18s ease,
    color 0.18s ease,
    background 0.18s ease;
}

.home-cover__btn--analysis {
  border: none;
  --el-button-text-color: #ffffff;
  --el-button-hover-text-color: #ffffff;
  --el-button-active-text-color: #ffffff;
  --el-button-bg-color: transparent;
  --el-button-hover-bg-color: transparent;
  --el-button-active-bg-color: transparent;
  --el-button-border-color: transparent;
  --el-button-hover-border-color: transparent;
  --el-button-active-border-color: transparent;
  background-image: linear-gradient(135deg, #4a7c62 0%, #5b8c7a 48%, #6fa888 100%);
  box-shadow: 0 6px 18px rgba(45, 107, 71, 0.28);
}

.home-cover__btn:hover {
  transform: translateY(-2px);
}

.home-cover__btn:active {
  transform: translateY(-3px);
}

.home-cover__btn:focus-visible {
  outline: 2px solid #5b8c7a;
  outline-offset: 3px;
}

.home-cover__btn--analysis:hover {
  box-shadow: 0 10px 26px rgba(45, 107, 71, 0.34);
  filter: saturate(1.05);
}

.home-cover__btn--analysis:active {
  box-shadow: 0 12px 30px rgba(25, 80, 52, 0.32);
}

.home-cover__btn--analysis :deep(.el-button),
.home-cover__btn--analysis :deep(.el-button:hover),
.home-cover__btn--analysis :deep(.el-button:active) {
  background-color: transparent !important;
  background-image: linear-gradient(135deg, #4a7c62 0%, #5b8c7a 48%, #6fa888 100%) !important;
}

.home-cover__btn--analysis :deep(.el-button:hover) {
  background-image: linear-gradient(135deg, #4f856b 0%, #609382 48%, #76b193 100%) !important;
}

.home-cover__btn--analysis :deep(.el-button:active) {
  background-image: linear-gradient(135deg, #3f6d55 0%, #4f7f6d 48%, #5f9a7c 100%) !important;
}

/* P2：分析页工具标题行（整体放大） */
.top-bar {
  display: grid;
  grid-template-columns: minmax(0, auto) 1fr;
  align-items: center;
  gap: 16px 32px;
  margin-bottom: 18px;
  padding: 10px 4px 12px;
  flex-shrink: 0;
}

.top-bar .brand {
  display: flex;
  align-items: center;
  min-width: 0;
}

.name {
  font-weight: 800;
  font-size: clamp(1.45rem, 2.8vw, 1.85rem);
  line-height: 1.2;
  letter-spacing: -0.03em;
  color: #1a2420;
  text-shadow: 0 1px 0 rgba(255, 255, 255, 0.85);
}

.tagline {
  margin: 0;
  justify-self: stretch;
  width: 100%;
  text-align: right;
  color: #4a564e;
  font-size: clamp(16px, 0.55vw + 15px, 19px);
  font-weight: 500;
  line-height: 1.5;
  letter-spacing: 0.04em;
  max-width: none;
  white-space: nowrap;
}

.top-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
}

/* 顶栏语言：绿色系滑动块，与 mode-slide 同源设计语言 */
.lang-slide {
  flex-shrink: 0;
}

.lang-slide__track {
  position: relative;
  display: flex;
  gap: 3px;
  padding: 5px;
  border-radius: 999px;
  background: linear-gradient(165deg, #c5d9ce 0%, #dce8e2 45%, #d2e0d8 100%);
  border: 1px solid rgba(61, 107, 82, 0.18);
  box-shadow:
    inset 0 2px 4px rgba(45, 70, 55, 0.08),
    inset 0 -1px 0 rgba(255, 255, 255, 0.5),
    0 2px 10px rgba(45, 107, 71, 0.07);
}

.lang-slide__thumb {
  position: absolute;
  top: 4px;
  bottom: 4px;
  left: 4px;
  width: calc(50% - 5.5px);
  border-radius: 999px;
  background: linear-gradient(180deg, #ffffff 0%, #f4faf7 100%);
  box-shadow:
    0 3px 10px rgba(45, 107, 71, 0.12),
    0 1px 2px rgba(0, 0, 0, 0.04),
    inset 0 1px 0 rgba(255, 255, 255, 1),
    inset 0 -1px 0 rgba(91, 140, 122, 0.06);
  transition: transform 0.38s cubic-bezier(0.34, 1.15, 0.64, 1);
  pointer-events: none;
  z-index: 0;
  will-change: transform;
}

.lang-slide__track--en .lang-slide__thumb {
  transform: translateX(calc(100% + 3px));
}

.lang-slide__btn {
  position: relative;
  z-index: 1;
  flex: 1;
  min-width: 3.25rem;
  margin: 0;
  padding: 7px 14px;
  border: none;
  background: transparent;
  font-family: inherit;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.04em;
  line-height: 1.25;
  white-space: nowrap;
  color: #5a7268;
  cursor: pointer;
  border-radius: 999px;
  transition: color 0.28s ease;
}

.lang-slide__btn:hover {
  color: #2d4a38;
}

.lang-slide__btn.is-active {
  color: #0f4d2f;
  font-weight: 700;
}

.lang-slide__btn:focus {
  outline: none;
}

.lang-slide__btn:focus-visible {
  outline: 2px solid #5b8c7a;
  outline-offset: 2px;
}

/* 通栏：玻璃质感外壳 + 嵌入式分段控件 */
.mode-bar {
  margin-bottom: 16px;
  flex-shrink: 0;
}

.mode-bar__inner {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px 16px;
  padding: 12px 16px;
  border-radius: 16px;
  background: linear-gradient(
    145deg,
    rgba(255, 255, 255, 0.88) 0%,
    rgba(245, 252, 248, 0.75) 48%,
    rgba(255, 255, 255, 0.65) 100%
  );
  border: 1px solid rgba(91, 140, 122, 0.14);
  box-shadow:
    0 10px 40px rgba(45, 107, 71, 0.08),
    0 1px 0 rgba(255, 255, 255, 0.95) inset;
  backdrop-filter: blur(10px);
}

.mode-bar__badge {
  flex: 0 0 auto;
  display: inline-flex;
  align-items: center;
  padding: 6px 14px;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: 0.06em;
  color: #3d6b52;
  background: linear-gradient(135deg, rgba(91, 140, 122, 0.14), rgba(255, 255, 255, 0.55));
  border: 1px solid rgba(91, 140, 122, 0.22);
  box-shadow: 0 1px 3px rgba(45, 90, 65, 0.06);
}

.page.en .mode-bar__badge {
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.mode-bar .mode-slide {
  flex: 1 1 260px;
  min-width: min(100%, 220px);
}

@media (max-width: 960px) {
  .mode-bar__inner {
    flex-direction: column;
    align-items: stretch;
  }

  .mode-bar .mode-slide {
    min-width: 0;
  }
}

.layout {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) minmax(0, 2fr);
  gap: 20px;
  align-items: stretch;
}

/* 父级 .analysis-view 给出剩余视口高度后，本行占满该高度（否则 1fr 无法分配，左下板块拉不长） */
.analysis-view .layout {
  flex: 1 1 auto;
  min-height: 0;
  grid-template-rows: minmax(0, 1fr);
}

.col {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 0;
  min-height: 0;
}

.col.left {
  gap: 12px;
  min-height: 0;
}

/* 左右两列铺满各自网格轨道；stretch 时占满行高，便于左栏底对齐 */
.col.left,
.col.right {
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  align-self: stretch;
}

.layout > .col.left > .upload-card,
.layout > .col.left > .col-left-fill,
.layout > .col.right > .col-right-panel {
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

/* 占满左栏除上传外的剩余高度：绿表单 flex 拉高与右栏对齐，按钮贴底 */
.col-left-fill {
  flex: 1 1 auto;
  display: flex;
  flex-direction: column;
  min-height: 0;
  width: 100%;
}

.col-left-fill .param-form {
  flex: 1 1 auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow-x: hidden;
  overflow-y: auto;
  margin-bottom: 0;
}

/* 左栏参数：固定字号与控件高度，不随卡片拉高而伸缩 */
.col-left-fill .param-form > .param-form-section :deep(.el-form-item) {
  margin-bottom: 22px;
}

.col-left-fill .param-form > .param-form-section :deep(.el-form-item:last-child) {
  margin-bottom: 0;
}

.col-left-fill .param-form > .param-form-section :deep(.el-form-item__label) {
  font-size: 16px;
  margin-bottom: 8px !important;
}

.col-left-fill .param-form > .param-form-section :deep(.el-select .el-select__wrapper),
.col-left-fill .param-form > .param-form-section :deep(.el-select .el-input__wrapper),
.col-left-fill .param-form > .param-form-section :deep(.el-input__wrapper) {
  min-height: 48px;
  height: auto;
  align-items: center;
  padding-top: 10px;
  padding-bottom: 10px;
}

.col-left-fill .param-form > .param-form-section :deep(.el-input__inner),
.col-left-fill .param-form > .param-form-section :deep(.el-select__selected-item),
.col-left-fill .param-form > .param-form-section :deep(.el-select__placeholder) {
  font-size: 16px;
  line-height: 1.45;
}

.col-left-fill .run-main {
  margin-top: 12px;
  flex-shrink: 0;
}

.col-left-bottom-spacer {
  flex: 0 0 0;
  height: 0;
  min-height: 0;
  min-width: 0;
  overflow: hidden;
  pointer-events: none;
}

.col.right {
  gap: 0;
}

.col.right .col-right-panel {
  flex: 1 1 auto;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.col.right .col-right-panel .preview-card--inset {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.col.right .col-right-panel .preview-card--inset :deep(.el-card__body) {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.col.right .col-right-panel .style-card--inset {
  flex-shrink: 0;
}

@media (max-width: 960px) {
  .page {
    padding: 0 14px 32px;
  }

  .site-nav {
    flex-direction: column;
    align-items: stretch;
    padding: 10px 14px;
    margin: 0 calc(50% - 50vw) 16px;
  }

  .site-nav__menu {
    justify-content: center;
    flex-wrap: wrap;
    margin-left: 0;
  }

  .site-nav__lang-wrap {
    justify-content: center;
    width: 100%;
    margin-left: 0;
    padding-top: 4px;
    border-top: 1px solid rgba(91, 140, 122, 0.14);
  }

  .site-nav__lang-divider {
    display: none;
  }

  .analysis-shell {
    flex-direction: column;
    min-height: auto;
  }

  .analysis-shell.is-sidebar-collapsed .analysis-sidebar {
    width: 100%;
    padding: 0;
    background: #000000;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    min-height: 52px;
  }

  .analysis-shell.is-sidebar-collapsed .analysis-sidebar-toggle {
    position: static;
    transform: none;
    margin-left: 0;
  }

  .analysis-shell.is-sidebar-collapsed .analysis-sidebar-toggle__icon {
    transform: rotate(180deg);
  }

  .analysis-sidebar {
    width: 100%;
    flex-direction: column;
    flex-wrap: nowrap;
    align-items: stretch;
    padding: 12px 14px;
    gap: 0;
  }

  .analysis-sidebar__head {
    width: 100%;
    padding: 0 0 10px;
  }

  .analysis-sidebar__body {
    width: 100%;
    padding-right: 0;
  }

  .analysis-sidebar-toggle {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
  }

  .analysis-sidebar__title-row {
    width: auto;
    padding: 0 8px;
  }

  .analysis-sidebar__nav {
    flex-direction: row;
    flex-wrap: wrap;
    flex: 1;
    gap: 6px;
  }

  .analysis-sidebar__item {
    width: auto;
    border-radius: 999px;
    padding: 8px 14px;
    background: rgba(255, 255, 255, 0.08);
  }

  .analysis-sidebar__note {
    width: 100%;
    margin: 0;
  }

  .analysis-hub {
    padding: 8px 0 32px;
  }

  .analysis-shell__main {
    padding: 18px 16px 20px 20px;
  }

  .analysis-hub__cards {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 16px;
    max-width: none;
  }

  .analysis-hub__card-preview {
    min-height: 160px;
  }

  .analysis-hub__card-preview svg {
    min-height: 160px;
  }

  .home-cover {
    min-height: auto;
  }

  .layout {
    grid-template-columns: 1fr;
  }
  .analysis-view .layout {
    grid-template-rows: none;
    flex: none;
    min-height: 0;
  }
  .col.left {
    gap: 12px;
    min-height: 0;
  }
  .col-left-fill {
    flex: 0 1 auto;
    min-height: 0;
  }
  .col-left-bottom-spacer {
    flex: 0 0 0;
    display: none;
  }
  .col.left .param-form,
  .col-left-fill .param-form {
    flex: none;
    overflow-y: visible;
  }
  .col-left-fill .run-main {
    margin-top: 12px;
  }
  .col.right .col-right-panel .preview-card--inset {
    flex: none;
    min-height: auto;
  }
  .col.right .col-right-panel .preview-card--inset :deep(.el-card__body) {
    flex: none;
    min-height: auto;
  }
  .top-bar {
    grid-template-columns: 1fr;
    text-align: center;
  }

  .top-bar .tagline {
    text-align: center;
    letter-spacing: 0.02em;
    white-space: normal;
  }
  .top-actions {
    justify-content: center;
  }
}

/* KEGG / GO：滑动指示块（单块滑轨 + 文字叠在上方） */
.mode-slide {
  width: 100%;
  box-sizing: border-box;
}

.mode-slide__track {
  position: relative;
  display: flex;
  gap: 3px;
  padding: 4px;
  border-radius: 12px;
  background: linear-gradient(180deg, #cfddd4 0%, #e4eee8 55%, #dde8e2 100%);
  box-shadow:
    inset 0 2px 5px rgba(45, 70, 55, 0.07),
    inset 0 -1px 0 rgba(255, 255, 255, 0.45);
}

.mode-slide__thumb {
  position: absolute;
  top: 4px;
  bottom: 4px;
  left: 4px;
  width: calc(50% - 6px);
  border-radius: 9px;
  background: linear-gradient(180deg, #ffffff 0%, #f8fcfa 100%);
  box-shadow:
    0 4px 14px rgba(45, 107, 71, 0.14),
    0 1px 3px rgba(0, 0, 0, 0.05),
    inset 0 1px 0 rgba(255, 255, 255, 0.95);
  transition: transform 0.4s cubic-bezier(0.34, 1.18, 0.64, 1);
  pointer-events: none;
  z-index: 0;
  will-change: transform;
}

.mode-slide__track--go .mode-slide__thumb {
  transform: translateX(calc(100% + 4px));
}

.mode-slide__btn {
  position: relative;
  z-index: 1;
  flex: 1;
  margin: 0;
  border: none;
  background: transparent;
  padding: 11px 14px;
  min-height: 48px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0.03em;
  line-height: 1.35;
  color: #5c7268;
  cursor: pointer;
  border-radius: 12px;
  font-family: inherit;
  transition: color 0.28s ease;
}

.mode-slide__btn:hover {
  color: #2a4536;
}

.mode-slide__btn.is-active {
  color: #145a38;
  font-weight: 700;
}

.mode-slide__btn:focus {
  outline: none;
}

.mode-slide__btn:focus-visible {
  outline: 2px solid #5b8c7a;
  outline-offset: 2px;
}

/* 左右首张白卡：统一标题行与内容区内边距，横向对齐 */
.upload-card:not(.upload-card--dashed-wrap) :deep(.el-card__header) {
  padding: 12px 18px;
}

.upload-card:not(.upload-card--dashed-wrap) :deep(.el-card__body),
.preview-card :deep(.el-card__body) {
  padding: 16px 18px;
}

.upload-card--dashed-wrap :deep(.el-card__header) {
  display: none;
}

.upload-card--dashed-wrap :deep(.el-card) {
  border: none;
  background: transparent;
  box-shadow: none;
}

/* 玻璃底与阴影（左栏单块、右栏整块共用变量） */
.upload-card--dashed-wrap,
.param-form,
.col-right-panel,
.preview-card--inset,
.style-card--inset {
  --analysis-glass-bg:
    linear-gradient(165deg, rgba(255, 255, 255, 0.97) 0%, rgba(245, 250, 247, 0.92) 42%, #fbfcfa 100%),
    radial-gradient(ellipse 120% 80% at 100% 0%, rgba(91, 140, 122, 0.06), transparent 55%);
  --analysis-glass-shadow:
    0 8px 28px rgba(45, 90, 65, 0.07),
    inset 0 0 0 1px rgba(255, 255, 255, 0.65);
  --analysis-glass-shadow-hover:
    0 12px 36px rgba(45, 90, 65, 0.1),
    inset 0 0 0 1px rgba(255, 255, 255, 0.75);
}

/* 左栏 + 右栏统一淡绿外框 */
.upload-card--dashed-wrap,
.param-form,
.col-right-panel {
  --analysis-panel-outline: 2px solid rgba(74, 124, 98, 0.38);
  box-sizing: border-box;
  border-radius: 16px;
  border: var(--analysis-panel-outline);
  background: var(--analysis-glass-bg);
  box-shadow: var(--analysis-glass-shadow);
  transition:
    box-shadow 0.28s ease,
    border-color 0.28s ease;
}

.upload-card--dashed-wrap:hover,
.param-form:hover,
.col-right-panel:hover {
  border-color: rgba(74, 124, 98, 0.52);
  box-shadow: var(--analysis-glass-shadow-hover);
}

/* 右栏内：预览 + 样式无独立外框，由 col-right-panel 统一包裹 */
.preview-card--inset,
.style-card--inset {
  border: none !important;
  border-radius: 0 !important;
  box-shadow: none !important;
  background: transparent !important;
}

.preview-card--inset :deep(.el-card),
.style-card--inset :deep(.el-card) {
  border: none;
  box-shadow: none;
  background: transparent;
}

.style-card--inset {
  border-top: 1px solid rgba(91, 140, 122, 0.22) !important;
}

.upload-card--dashed-wrap :deep(.el-card__body) {
  padding: 14px;
  background: transparent;
}

/* P2 结果展示（外框由 col-right-panel 承担） */
.preview-card--inset {
  --el-card-border-color: transparent;
}

.preview-card--inset :deep(.el-card__header) {
  padding: 15px 22px;
  background: transparent;
  border-bottom: 1px solid rgba(91, 140, 122, 0.12);
}

/* P4 样式面板（外框由 col-right-panel 承担） */
.style-card--inset {
  --style-inner-font: 16px;
  --style-inner-label: 17px;
  --el-color-primary: #4a7c62;
  --el-color-primary-light-3: #6a9e86;
  --el-color-primary-light-5: #8eb8a3;
  --el-color-primary-light-7: #b5d0c2;
  --el-color-primary-light-9: #e8f2ec;
  --el-color-primary-dark-2: #3a654f;
  font-size: var(--style-inner-font);
}

.style-card--inset :deep(.el-card__header) {
  padding: 15px 22px;
  background: transparent;
  border-bottom: 1px solid rgba(91, 140, 122, 0.12);
}

.style-card--inset :deep(.el-card__body) {
  padding: 16px 18px;
  background: transparent;
}

.style-card--inset .field > label,
.style-card--inset .field label,
.style-card--inset .axis-bold-entry-ref > label {
  font-size: var(--style-inner-label);
}

.style-card :deep(.el-input__inner),
.style-card :deep(.el-input-number .el-input__inner),
.style-card :deep(.el-select__wrapper),
.style-card :deep(.el-select__selected-item),
.style-card :deep(.el-select__placeholder) {
  font-size: var(--style-inner-font);
}

.style-card :deep(.el-switch__label) {
  font-size: 15px;
}

.card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.formats {
  font-size: 13px;
  color: #7a8a7d;
  font-weight: 500;
}

.muted {
  color: #7a8a7d;
  font-size: 14px;
  line-height: 1.5;
  margin: 0 0 12px;
}

.btn-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.soft {
  background: #fff;
  border-color: #d9e5db;
}

.primary-blue {
  background: #5b8c7a;
  border-color: #5b8c7a;
}

/* 参考 degXY：浅灰虚线、大圆角，框内标题 + 说明 + 按钮行 */
.file-drop-panel {
  position: relative;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  min-height: 220px;
  border: none;
  border-radius: 12px;
  background: transparent;
  padding: 10px 10px 6px;
  cursor: pointer;
  outline: none;
  transition: background 0.2s ease;
}

.file-drop-panel:focus-visible {
  outline: 2px solid #5b8c7a;
  outline-offset: 3px;
}

.file-drop-panel.is-dragover {
  background: rgba(237, 245, 240, 0.85);
}

.file-drop-panel__input {
  position: absolute;
  width: 1px;
  height: 1px;
  opacity: 0;
  pointer-events: none;
}

.file-drop-panel__click-area {
  flex: 1;
  min-height: 36px;
  border-radius: 10px;
  margin: -4px -4px 0;
  padding: 2px 4px 0;
}

/* P3：上传区（仅放大字体） */
.file-drop-panel__title {
  margin: 0 0 10px;
  font-size: 1.3rem;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.45;
}

.file-drop-panel__ext {
  font-weight: 600;
  color: #4d5e54;
  font-size: 0.9em;
}

.file-drop-panel__hint {
  margin: 0 0 8px;
  font-size: 16px;
  line-height: 1.55;
}

.file-drop-panel__drop-hint {
  margin: 0 0 16px;
  font-size: 16px;
  color: #7a8680;
  line-height: 1.55;
}

.file-drop-panel__actions {
  margin-top: 4px;
  flex-wrap: wrap;
  cursor: default;
}

.file-drop-panel__actions :deep(.el-button) {
  font-size: 15px;
}

.file-drop-panel__actions .file-status {
  margin-left: auto;
  font-size: 15px;
  color: #9aa89f;
  max-width: min(100%, 280px);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  text-align: right;
}

.file-drop-panel__actions .file-status.has-file {
  color: #2f6b4a;
  font-weight: 500;
}

.example-dropdown {
  vertical-align: middle;
}

.example-caret {
  margin-left: 4px;
  font-size: 11px;
  opacity: 0.75;
}

/* P3 参数区 */
.param-form {
  position: relative;
  padding: 16px 18px 16px 22px;
  overflow: hidden;
}

.param-form::before {
  content: "";
  position: absolute;
  left: 0;
  top: 16px;
  bottom: 16px;
  width: 4px;
  border-radius: 0 6px 6px 0;
  background: linear-gradient(180deg, #4a7c62 0%, #6fa888 50%, #8ec4a8 100%);
  opacity: 0.88;
  pointer-events: none;
}

.param-form-section__head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.param-form-section__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  color: #4a7c62;
  background: linear-gradient(145deg, rgba(91, 140, 122, 0.12), rgba(255, 255, 255, 0.85));
  border: 1px solid rgba(91, 140, 122, 0.18);
  flex-shrink: 0;
}

.param-form-section__icon svg {
  width: 26px;
  height: 26px;
}

/* P1：分析与筛选等 — 与「结果展示」同系标题字 */
.param-form-section__title {
  font-size: 1.3rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  color: #1e2a24;
  line-height: 1.28;
}

.page.en .param-form-section__title {
  letter-spacing: 0.04em;
}

.param-form-section {
  border: none;
  border-radius: 0;
  padding: 0;
  background: transparent;
  box-sizing: border-box;
}

.param-form-section--divider {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid rgba(91, 140, 122, 0.22);
}

/* 上一节最后一项与虚线之间不留大块空 */
.param-form-section:first-of-type :deep(.el-form-item:last-child) {
  margin-bottom: 0;
}

.param-form-section--divider .param-form-section__head {
  margin-bottom: 12px;
}

.param-form :deep(.el-form-item) {
  margin-bottom: 14px;
  display: block;
  width: 100%;
}

.param-form-section:last-of-type :deep(.el-form-item:last-child) {
  margin-bottom: 0;
}

/* 标签在上时：控件与卡片同宽，与下方「生成」按钮左右缘对齐 */
.param-form :deep(.el-form-item__content) {
  display: block;
  width: 100%;
  max-width: 100%;
}

.param-form :deep(.el-select),
.param-form :deep(.el-input),
.param-form :deep(.el-input-number) {
  width: 100%;
}

.param-form :deep(.el-form-item__label) {
  color: #4a5c52;
  font-weight: 600;
  font-size: 14px;
  line-height: 1.4;
  margin-bottom: 6px !important;
}

.param-form :deep(.el-input__wrapper),
.param-form :deep(.el-select .el-input__wrapper) {
  background-color: rgba(255, 255, 255, 0.92);
  box-shadow: 0 0 0 1px rgba(91, 140, 122, 0.14) inset;
  transition: box-shadow 0.2s ease, background 0.2s ease;
}

.param-form :deep(.el-input-number .el-input__wrapper) {
  background-color: rgba(255, 255, 255, 0.92);
  box-shadow: 0 0 0 1px rgba(91, 140, 122, 0.14) inset;
}

.param-form :deep(.el-input__wrapper:hover),
.param-form :deep(.el-select:hover .el-input__wrapper),
.param-form :deep(.el-input-number:hover .el-input__wrapper) {
  box-shadow: 0 0 0 1px rgba(91, 140, 122, 0.32) inset;
}

.param-form :deep(.el-input__wrapper.is-focus),
.param-form :deep(.el-select .el-input__wrapper.is-focus),
.param-form :deep(.el-input-number .el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px #5b8c7a inset, 0 0 0 3px rgba(91, 140, 122, 0.12);
}

/* 生成图表：主题墨绿渐变（与首页「立即分析」同系） */
.run-main.el-button--primary {
  --el-button-text-color: #ffffff;
  --el-button-hover-text-color: #ffffff;
  --el-button-active-text-color: #ffffff;
  --el-button-bg-color: transparent;
  --el-button-hover-bg-color: transparent;
  --el-button-active-bg-color: transparent;
  --el-button-border-color: transparent;
  --el-button-hover-border-color: transparent;
  --el-button-active-border-color: transparent;
  --el-button-disabled-bg-color: #b5d0c2;
  --el-button-disabled-border-color: transparent;
  --el-button-disabled-text-color: #f5faf7;
  width: 100%;
  border-radius: 14px;
  height: 48px;
  font-size: 17px;
  font-weight: 600;
  letter-spacing: 0.03em;
  border: none !important;
  background-color: transparent !important;
  background-image: linear-gradient(135deg, #3d6b52 0%, #4a7c62 46%, #5b8c7a 100%) !important;
  box-shadow: 0 4px 14px rgba(45, 90, 65, 0.22);
  transition:
    background-image 0.22s ease,
    box-shadow 0.22s ease,
    filter 0.22s ease;
}

.run-main.el-button--primary:hover,
.run-main.el-button--primary:focus-visible {
  filter: none;
  background-image: linear-gradient(135deg, #456f58 0%, #528672 46%, #659286 100%) !important;
  box-shadow: 0 6px 18px rgba(45, 90, 65, 0.26);
}

.run-main.el-button--primary:active {
  background-image: linear-gradient(135deg, #355a47 0%, #3f6d55 46%, #4f7f6d 100%) !important;
  box-shadow: 0 2px 10px rgba(45, 90, 65, 0.18);
}

.run-main.el-button--primary:focus-visible {
  outline: 2px solid #5b8c7a;
  outline-offset: 2px;
}

/* P3：结果展示 — 区块标题基准 */
.preview-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 700;
  font-size: 1.3rem;
  letter-spacing: 0.04em;
  color: #1e2a24;
}

.preview-head__title {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  min-width: 0;
}

.preview-head__params-link {
  font-weight: 600;
  font-size: 0.92em;
  margin-left: 2px;
}

.preview-head__source-tag {
  font-weight: 700 !important;
  letter-spacing: 0.06em;
  border-radius: 999px !important;
}

.preview-head__actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.preview-head :deep(.el-tag) {
  font-size: 14px;
  padding: 4px 12px;
  font-weight: 600;
}

.preview-download {
  font-weight: 600;
}

.preview-download-tooltip-trigger {
  display: inline-flex;
  vertical-align: middle;
}

.preview-pdf-tooltip {
  display: inline-block;
  max-width: min(320px, 78vw);
  line-height: 1.45;
  font-size: 13px;
}

.preview-format-tag.preview-format-tag--muted {
  opacity: 0.42;
  font-weight: 500;
}

.style-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.style-head--with-subtabs {
  align-items: flex-start;
}

@media (min-width: 560px) {
  .style-head--with-subtabs {
    align-items: center;
  }
}

.style-subtabs {
  flex: 1 1 200px;
  min-width: 0;
  max-width: 100%;
}

.style-subtabs__track {
  position: relative;
  display: flex;
  gap: 4px;
  padding: 5px;
  border-radius: 14px;
  background: linear-gradient(180deg, #cfddd4 0%, #e4eee8 58%, #dde8e2 100%);
  border: 1px solid rgba(91, 140, 122, 0.16);
  box-shadow: inset 0 2px 4px rgba(45, 70, 55, 0.06);
  max-width: 460px;
}

.style-subtabs__thumb {
  position: absolute;
  top: 5px;
  bottom: 5px;
  left: 5px;
  width: calc(50% - 7px);
  border-radius: 10px;
  background: linear-gradient(180deg, #ffffff 0%, #f8fcfa 100%);
  box-shadow:
    0 3px 12px rgba(45, 107, 71, 0.12),
    0 1px 2px rgba(0, 0, 0, 0.04);
  transition: transform 0.38s cubic-bezier(0.34, 1.15, 0.64, 1);
  pointer-events: none;
  z-index: 0;
}

.style-subtabs__track--stats .style-subtabs__thumb {
  transform: translateX(calc(100% + 4px));
}

/* P2：样式与参数 / 统计结果 — 与「结果展示」同系标题字 */
.style-subtabs__btn {
  position: relative;
  z-index: 1;
  flex: 1;
  margin: 0;
  padding: 11px 14px;
  min-height: 48px;
  border: none;
  background: transparent;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  line-height: 1.28;
  color: #4a564e;
  cursor: pointer;
  border-radius: 10px;
  transition: color 0.25s ease;
}

.style-subtabs__btn:hover {
  color: #1e2a24;
}

.style-subtabs__btn.is-active {
  color: #1e2a24;
  font-weight: 700;
}

.style-subtabs__btn:focus {
  outline: none;
}

.style-subtabs__btn:focus-visible {
  outline: 2px solid #5b8c7a;
  outline-offset: 2px;
}

.style-tab-pane {
  min-height: 0;
}

.style-stats-page {
  padding-top: 2px;
  min-height: 340px;
}

.style-stats-intro {
  margin-bottom: 18px;
}

.style-stats-intro__title {
  margin: 0 0 8px;
  font-size: 17px;
  font-weight: 700;
  color: #355848;
  letter-spacing: 0.02em;
}

.style-stats-intro__hint {
  margin: 0;
  font-size: 14px;
  line-height: 1.55;
  color: #6a7a72;
}

.style-stats-kpis {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 18px;
}

@media (max-width: 560px) {
  .style-stats-kpis {
    grid-template-columns: 1fr;
  }
}

.style-stats-kpi {
  padding: 14px 16px;
  border-radius: 12px;
  background: linear-gradient(165deg, rgba(255, 255, 255, 0.95), rgba(246, 250, 247, 0.92));
  border: 1px solid rgba(91, 140, 122, 0.14);
  box-shadow: 0 4px 14px rgba(45, 90, 65, 0.05);
}

.style-stats-kpi__label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #5a7268;
  margin-bottom: 8px;
}

.style-stats-kpi__value {
  font-size: 22px;
  font-weight: 800;
  color: #2d6b47;
  letter-spacing: 0.02em;
}

.style-stats-param-line {
  margin: 0 0 14px;
  font-size: 13px;
  line-height: 1.55;
}

.style-stats-download-block,
.style-stats-sorted-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 14px;
  flex-wrap: wrap;
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid rgba(91, 140, 122, 0.14);
  background: linear-gradient(165deg, rgba(255, 255, 255, 0.96), rgba(245, 250, 247, 0.9));
  box-shadow: 0 4px 14px rgba(45, 90, 65, 0.05);
  margin-bottom: 12px;
}

.style-stats-download-title {
  font-size: 14px;
  font-weight: 700;
  color: #355848;
}

.style-stats-download-desc {
  margin: 6px 0 0;
  font-size: 13px;
  line-height: 1.5;
}

.style-stats-sorted-head {
  margin-bottom: 10px;
}

.style-stats-table-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
  margin: 10px 0 8px;
}

.style-stats-rows-total {
  font-size: 13px;
  font-weight: 600;
  color: #4a5f55;
}

.style-stats-page-controls {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.style-stats-page-select {
  width: 110px;
}

.style-stats-page-custom {
  width: 120px;
}

.style-stats-el-table {
  width: 100%;
}

.style-stats-pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
}

.style-stats-table-wrap {
  border-radius: 12px;
  border: 1px solid rgba(91, 140, 122, 0.12);
  overflow: hidden;
  background: rgba(255, 255, 255, 0.88);
}

.style-stats-table-cap {
  padding: 8px 14px;
  font-size: 12px;
  font-weight: 600;
  color: #7a8a82;
  letter-spacing: 0.03em;
  background: rgba(91, 140, 122, 0.06);
  border-bottom: 1px solid rgba(91, 140, 122, 0.1);
}

.style-stats-table-head {
  display: grid;
  grid-template-columns: minmax(72px, 0.9fr) minmax(100px, 2fr) 0.45fr 0.45fr 0.55fr;
  gap: 8px;
  padding: 10px 14px;
  font-size: 12px;
  font-weight: 700;
  color: #3d5c4a;
  letter-spacing: 0.04em;
  border-bottom: 1px dashed rgba(91, 140, 122, 0.22);
}

.page.en .style-stats-table-head {
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.style-stats-table-body {
  padding: 10px 14px 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.style-stats-skel-row {
  display: grid;
  grid-template-columns: minmax(72px, 0.9fr) minmax(100px, 2fr) 0.45fr 0.45fr 0.55fr;
  gap: 8px;
  align-items: center;
}

.style-stats-skel {
  display: block;
  height: 10px;
  border-radius: 5px;
  background: #e2ebe4;
}

.style-stats-skel--short {
  max-width: 56px;
}

.style-stats-skel--mid {
  max-width: 36px;
}

.style-stats-skel--num {
  max-width: 42px;
}

.style-stats-skel--long {
  max-width: 100%;
}

.preview-box {
  position: relative;
  flex: 1;
  min-height: 280px;
  background: linear-gradient(180deg, #f8faf9 0%, #eef3f0 100%);
  border: none;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 12px;
  transition: background 0.22s ease;
}

.preview-box--drawing .plot-img-host,
.preview-box--drawing .preview-empty {
  pointer-events: none;
  user-select: none;
  filter: saturate(0.88) brightness(0.96);
  opacity: 0.45;
}

.preview-drawing-overlay {
  position: absolute;
  inset: 10px;
  z-index: 6;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 14px;
  padding: 20px 16px;
  text-align: center;
  border-radius: 10px;
  background: rgba(252, 254, 253, 0.92);
  border: 1px solid rgba(91, 140, 122, 0.22);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.65);
  backdrop-filter: blur(3px);
}

.preview-drawing-spinner {
  width: 46px;
  height: 46px;
  border-radius: 50%;
  border: 3px solid rgba(91, 140, 122, 0.22);
  border-top-color: #4a7c62;
  animation: preview-drawing-spin 0.78s linear infinite;
}

@keyframes preview-drawing-spin {
  to {
    transform: rotate(360deg);
  }
}

.preview-drawing-title {
  margin: 0;
  font-size: 17px;
  font-weight: 700;
  color: #2d5244;
  letter-spacing: 0.03em;
}

.preview-drawing-bar {
  width: min(300px, 88%);
  height: 5px;
  border-radius: 999px;
  background: rgba(91, 140, 122, 0.18);
  overflow: hidden;
}

.preview-drawing-bar__fill {
  height: 100%;
  width: 38%;
  border-radius: 999px;
  background: linear-gradient(90deg, #4a7c62, #6fa888);
  animation: preview-drawing-bar 1.35s ease-in-out infinite;
}

@keyframes preview-drawing-bar {
  0% {
    transform: translateX(-120%);
  }
  100% {
    transform: translateX(320%);
  }
}

.preview-drawing-hint {
  margin: 0;
  max-width: 34rem;
  font-size: 13px;
  line-height: 1.55;
  color: #5c6f65;
}

.plot-img-host {
  position: relative;
  display: inline-block;
  max-width: 100%;
}

.plot-img-host .plot-img {
  display: block;
}

.pathway-picker-bar {
  margin: 10px 0 0;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.pathway-picker-bar__label {
  font-size: 13px;
  font-weight: 600;
  color: #43594e;
}

.pathway-picker-bar__select {
  flex: 1 1 320px;
  min-width: min(100%, 220px);
}

.preview-pathway-hint {
  margin: 10px 4px 0;
  font-size: 13px;
  line-height: 1.45;
  text-align: center;
}

.preview-pathway-highlight-note {
  margin: 6px 4px 0;
  font-size: 12px;
  line-height: 1.45;
  text-align: center;
  color: #8b1f1f;
}

.plot-confirm-hint {
  margin: 0 0 12px;
  font-size: 13px;
  line-height: 1.5;
}

.plot-confirm-changes-intro {
  margin: 0 0 8px;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.5;
  color: #b42318;
}

.plot-confirm-changes-list {
  margin: 0 0 14px;
  padding: 10px 12px 10px 28px;
  list-style: disc;
  font-size: 13px;
  line-height: 1.55;
  background: rgba(220, 38, 38, 0.06);
  border: 1px solid rgba(220, 38, 38, 0.18);
  border-radius: 10px;
}

.plot-confirm-changes-list li + li {
  margin-top: 6px;
}

.plot-confirm-changes-label {
  font-weight: 600;
  color: #991b1b;
}

.plot-confirm-changes-diff,
.plot-confirm-dd--changed .plot-confirm-old,
.plot-confirm-dd--changed .plot-confirm-new {
  color: #dc2626;
  font-weight: 600;
}

.plot-confirm-old {
  text-decoration: line-through;
  text-decoration-color: rgba(220, 38, 38, 0.45);
}

.plot-confirm-arrow {
  margin: 0 5px;
  color: #b91c1c;
  font-weight: 700;
}

.plot-confirm-dt--changed {
  color: #b42318;
}

.plot-confirm-params-scroll {
  max-height: min(48vh, 380px);
  overflow-y: auto;
  overflow-x: hidden;
  overscroll-behavior: contain;
  scrollbar-gutter: stable;
}

.plot-confirm-dl {
  margin: 0;
  display: grid;
  grid-template-columns: minmax(98px, 148px) 1fr;
  gap: 8px 12px;
  font-size: 13px;
}

.plot-confirm-dl dt {
  margin: 0;
  font-weight: 600;
  color: #3d5248;
}

.plot-confirm-dl dd {
  margin: 0;
  color: #2b2b2b;
  word-break: break-word;
}

.plot-confirm-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.pathway-detail-hint {
  margin: 0 0 14px;
  font-size: 13px;
  line-height: 1.5;
}

.pathway-gene-custom-panel {
  margin: 0 0 16px;
  padding: 12px 14px;
  border-radius: 10px;
  border: 1px solid rgba(74, 124, 98, 0.28);
  background: linear-gradient(180deg, rgba(248, 252, 249, 0.95) 0%, #fff 100%);
}

.pathway-gene-custom-panel__title {
  font-size: 14px;
  font-weight: 700;
  color: #2f4f3f;
  margin-bottom: 6px;
}

.pathway-gene-custom-panel__hint,
.pathway-gene-custom-panel__foot {
  margin: 0 0 10px;
  font-size: 12px;
  line-height: 1.45;
}

.pathway-gene-custom-panel__foot {
  margin: 10px 0 0;
}

.pathway-gene-auto-block,
.pathway-gene-custom-active-block {
  margin: 0 0 12px;
  padding: 8px 10px;
  border-radius: 8px;
  background: rgba(74, 124, 98, 0.06);
  border: 1px solid rgba(74, 124, 98, 0.12);
}

.pathway-gene-auto-block__label,
.pathway-gene-custom-active-block__label {
  font-size: 12px;
  font-weight: 600;
  color: #3d5248;
  margin-bottom: 4px;
}

.pathway-gene-auto-block__value,
.pathway-gene-custom-active-block__value {
  font-size: 13px;
  line-height: 1.5;
  word-break: break-word;
}

.pathway-gene-auto-block__note {
  margin: 6px 0 0;
  font-size: 11px;
  line-height: 1.4;
}

.pathway-gene-custom-panel__input-label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: #3d5248;
  margin-bottom: 6px;
}

.pathway-gene-custom-panel__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 10px;
}

.pathway-highlight-panel {
  margin: 0 0 14px;
  padding: 10px 12px;
  border-radius: 10px;
  border: 1px solid rgba(208, 74, 74, 0.2);
  background: linear-gradient(180deg, rgba(255, 248, 248, 0.9) 0%, rgba(255, 255, 255, 0.95) 100%);
}

.pathway-highlight-panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.pathway-highlight-panel__title {
  font-size: 13px;
  font-weight: 700;
  color: #8b1f1f;
}

.pathway-highlight-panel__hint {
  margin: 8px 0 0;
  font-size: 12px;
  line-height: 1.45;
}

.pathway-detail-dl {
  margin: 0;
  display: grid;
  grid-template-columns: minmax(96px, 140px) 1fr;
  gap: 8px 14px;
  font-size: 13px;
  align-items: start;
}

.pathway-detail-dl dt {
  margin: 0;
  font-weight: 600;
  color: #3d5248;
}

.pathway-detail-dl dd {
  margin: 0;
  word-break: break-word;
  white-space: pre-wrap;
}

.plot-img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
}

.preview-empty {
  text-align: center;
  max-width: 360px;
}

.empty-title {
  font-size: 22px;
  font-weight: 700;
  margin: 0 0 8px;
}

.tips {
  text-align: left;
  background: #fff;
  border-radius: 10px;
  padding: 10px 12px;
  margin: 14px 0;
  font-size: 13px;
  color: #6a756c;
}

/* 运行示例：浅绿底 + 墨绿描边，次级但仍属主题色 */
.run-example.el-button {
  --el-button-bg-color: #f0f7f3;
  --el-button-border-color: rgba(74, 124, 98, 0.55);
  --el-button-text-color: #3a654f;
  --el-button-hover-bg-color: #e8f2ec;
  --el-button-hover-border-color: #4a7c62;
  --el-button-hover-text-color: #2d5244;
  --el-button-active-bg-color: #dce9e2;
  --el-button-active-border-color: #3a654f;
  --el-button-active-text-color: #264530;
  border-radius: 12px;
  padding: 12px 28px;
  font-weight: 600;
  letter-spacing: 0.02em;
  border-width: 1px !important;
  background: #f0f7f3 !important;
  box-shadow: 0 2px 8px rgba(45, 90, 65, 0.08);
  transition:
    background 0.22s ease,
    border-color 0.22s ease,
    box-shadow 0.22s ease,
    color 0.22s ease;
}

.run-example.el-button:hover,
.run-example.el-button:focus-visible {
  background: #e8f2ec !important;
  box-shadow: 0 3px 10px rgba(45, 90, 65, 0.1);
}

.run-example.el-button:focus-visible {
  outline: 2px solid rgba(91, 140, 122, 0.45);
  outline-offset: 2px;
}

.style-grid {
  display: grid;
  gap: 14px 16px;
}

.style-grid--cols-3 {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

/**
 * 字号 / 气泡 / 画布等纯数字参数：按内容宽度排布，避免 el-input-number 占满整列。
 */
.style-grid--numeric-params {
  grid-template-columns: repeat(auto-fill, minmax(9.5rem, 12.75rem));
  justify-content: start;
  align-items: start;
}

/** 参数区：每行固定 4 列（气泡字号与字形等） */
.style-grid--params-4col {
  grid-template-columns: repeat(4, minmax(0, 1fr));
  width: 100%;
  gap: 10px 12px;
  align-items: end;
}

/** 条形图「字号与字形」：每行 3 列（3+3 两行） */
.style-grid--params-3col {
  grid-template-columns: repeat(3, minmax(0, 1fr));
  width: 100%;
  gap: 10px 12px;
  align-items: end;
}

.style-grid--params-4col > .field,
.style-grid--params-3col > .field {
  min-width: 0;
}

.style-grid--params-4col > .field > label,
.style-grid--params-4col .axis-bold-entry-ref > label,
.style-grid--params-3col > .field > label,
.style-grid--params-3col .axis-bold-entry-ref > label {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.style-grid--params-4col :deep(.el-input-number),
.style-grid--params-3col :deep(.el-input-number) {
  width: 100%;
}

.style-grid--numeric-params > .field {
  min-width: 0;
}

/* 气泡刻度：占两列网格，输入框比单格更长 */
.style-grid--numeric-params > .field--bubble-breaks {
  grid-column: span 2;
}

/* 气泡区：三列固定比例，刻度列略窄于原先「占两格」总宽 */
.style-grid--bubble-size-row.style-grid--numeric-params {
  grid-template-columns: minmax(8.75rem, 10.5rem) minmax(8.75rem, 10.5rem) minmax(11rem, 1fr);
  max-width: 100%;
}

.style-grid--bubble-size-row.style-grid--numeric-params > .field--bubble-breaks {
  grid-column: auto;
  min-width: 0;
}

.style-param-block--legend {
  margin-top: 16px;
}

/**
 * 图例六项单行：六列等分，控件在列内拉满，标题框与字号/色条/位置宽度视觉一致。
 */
.style-grid--legend-compact-one-row {
  display: grid;
  width: 100%;
  box-sizing: border-box;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  gap: 10px 12px;
  align-items: end;
}

.style-grid--legend-compact-one-row.style-grid--legend-bar {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.style-grid--legend-compact-one-row > .field {
  min-width: 0;
  width: 100%;
}

.field--legend-tight {
  min-width: 0;
}

.field--legend-tight :deep(.el-input) {
  width: 100%;
}

.field--legend-num :deep(.el-input-number) {
  width: 100%;
}

.field--legend-position {
  min-width: 0;
}

.field--legend-tight > label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #4d5e54;
  margin-bottom: 2px;
  line-height: 1.2;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.style-card .field.field--legend-tight > label {
  font-size: 13px;
  margin-bottom: 2px;
}

.field--legend-tight :deep(.el-input__wrapper) {
  padding: 1px 8px;
  min-height: 28px;
}

.field--legend-tight :deep(.el-input__inner) {
  font-size: 14px;
}

.field--legend-num :deep(.el-input-number .el-input__wrapper) {
  padding-left: 4px;
  padding-right: 4px;
  min-height: 28px;
}

.field--legend-tight :deep(.el-input-number__decrease),
.field--legend-tight :deep(.el-input-number__increase) {
  width: 18px;
}

.legend-compact-select {
  width: 100%;
}

.legend-compact-select :deep(.el-select__wrapper) {
  min-height: 28px;
  padding: 2px 8px;
  font-size: 14px;
}

.style-param-block {
  margin-top: 20px;
}

.style-param-block--folded {
  margin-top: 8px;
}

.style-param-block--folded .style-param-block__head {
  margin-bottom: 0;
}

.style-param-block__head--collapsible {
  cursor: pointer;
  user-select: none;
}

.style-param-block__head--collapsible:focus-visible {
  outline: 2px solid rgba(91, 140, 122, 0.45);
  outline-offset: 2px;
  border-radius: 6px;
}

.style-param-block__chevron {
  flex-shrink: 0;
  font-size: 10px;
  line-height: 1;
  color: #5b8c7a;
  transition: transform 0.2s ease;
  transform: rotate(-90deg);
}

.style-param-block__chevron.is-open {
  transform: rotate(0deg);
}

.style-param-block__body {
  padding-top: 2px;
}

.style-grid--basic-params {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 10px 12px;
  align-items: end;
  width: 100%;
}

/* 条形图基础参数：标题 / 轴 / TopN / 横坐标 / 显示基因 ID 共六列一行 */
.style-grid--basic-params--bar {
  grid-template-columns: repeat(6, minmax(0, 1fr));
}

.style-grid--basic-params--bar .field--bar-show-gene-id :deep(.el-switch) {
  height: 32px;
}

/* 条形图：开启「显示基因 ID」后，子参数在基础参数下第二行 */
.style-grid--basic-params--bar-gene {
  grid-template-columns: repeat(4, minmax(0, 1fr));
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed rgba(91, 140, 122, 0.22);
}

.style-grid--basic-params--bar-gene :deep(.el-input-number) {
  width: 100%;
}

/** 画布：宽度 / 高度 / 分辨率 — 三列等分占满一行 */
.style-grid--canvas-params {
  display: grid;
  width: 100%;
  box-sizing: border-box;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px 12px;
  align-items: end;
}

.style-grid--canvas-params > .field {
  min-width: 0;
}

.style-grid--canvas-params :deep(.el-input-number) {
  width: 100%;
}

.style-grid--basic-params > .field {
  min-width: 0;
}

.style-param-block--palette {
  margin-top: 0;
}

.style-param-block__head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
  min-width: 0;
}

.style-param-block__title {
  flex-shrink: 0;
  font-size: 1.05rem;
  font-weight: 700;
  letter-spacing: 0.03em;
  color: #2d5244;
}

.style-param-block__line {
  flex: 1;
  min-width: 16px;
  height: 1px;
  border-radius: 1px;
  background: linear-gradient(90deg, rgba(91, 140, 122, 0.45), rgba(91, 140, 122, 0.1) 70%, transparent);
}

.style-param-block--palette .style-top-block {
  margin-bottom: 0;
}

.field--axis-style-row {
  min-width: 0;
}

.axis-style-row__controls {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  width: 100%;
}

.axis-style-row__number {
  flex: 1 1 auto;
  min-width: 120px;
  max-width: 100%;
}

.field--axis-style-row .axis-style-row__number {
  width: 100%;
}

.field--axis-style-row :deep(.el-switch) {
  flex-shrink: 0;
}

.style-top-block {
  margin-bottom: 0;
}

.style-row-4 {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px 16px;
}

.axis-bold-popover-panel {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 2px 0 4px;
}

.axis-bold-popover-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  min-width: 0;
}

.axis-bold-popover-row__label {
  flex: 1;
  min-width: 0;
  font-size: 15px;
}

.field--grid-style-entry {
  position: relative;
  z-index: 2;
  min-width: 0;
}

/** 与同一网格内 el-input-number 列宽、纵向节奏一致 */
.field--axis-bold-entry {
  position: relative;
  z-index: 2;
  min-width: 0;
}

.axis-bold-entry-ref {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  width: 100%;
  gap: 0;
  cursor: pointer;
  outline: none;
}

.axis-bold-entry-ref > label {
  display: block;
  font-weight: 600;
  color: #4a5c52;
  margin-bottom: 6px;
  line-height: 1.35;
  cursor: pointer;
}

.axis-bold-entry-ref:focus-visible {
  border-radius: 8px;
  box-shadow: 0 0 0 2px rgba(91, 140, 122, 0.35);
}

.field--axis-bold-entry :deep(.grid-style-expand-btn.el-button) {
  width: 100%;
  box-sizing: border-box;
  justify-content: center;
  margin: 0;
}

.grid-style-entry-ref {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 4px;
  width: 100%;
  cursor: pointer;
  outline: none;
}

.grid-style-entry-ref:focus-visible {
  border-radius: 8px;
  box-shadow: 0 0 0 2px rgba(91, 140, 122, 0.35);
}

.grid-style-expand-btn {
  width: auto;
  align-self: flex-start;
  border-radius: 8px;
  padding: 5px 12px;
  font-size: 15px;
}

.grid-style-chevron {
  display: inline-block;
  margin-left: 6px;
  font-size: 10px;
  transition: transform 0.2s ease;
}

.grid-style-chevron.is-open {
  transform: rotate(-180deg);
}

.style-grid-style-panel {
  border: 1px solid rgba(91, 140, 122, 0.22);
  background: rgba(248, 252, 250, 0.88);
}

/** 浮层内：宽度由 el-popover :width 决定，内容铺满 */
.style-grid-style-panel--popover {
  box-sizing: border-box;
  width: 100%;
  margin: 0;
  padding: 0;
  border: none;
  background: transparent;
  box-shadow: none;
}

.grid-style-section--minor {
  margin-top: 10px;
  padding-top: 8px;
  border-top: 1px dashed rgba(91, 140, 122, 0.2);
}

.grid-style-tier-title {
  margin: 0 0 6px;
  font-size: 14px;
  font-weight: 700;
  color: #4a5c52;
  line-height: 1.3;
}

.grid-line-pair {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 6px 12px;
  align-items: start;
}

.field--grid-line-compact label {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 4px;
  color: #5a6b62;
}

.color-row--grid-line-hex {
  gap: 6px;
  min-width: 0;
}

.color-row--grid-line-hex :deep(.el-input) {
  flex: 1 1 auto;
  min-width: 0;
  max-width: 118px;
}

.color-row--grid-line-hex :deep(.el-input .el-input__wrapper) {
  padding: 2px 8px;
}

.color-row--grid-line-hex :deep(.el-input__inner) {
  font-size: 14px;
}

.grid-line-width-input {
  width: 100%;
}

.grid-line-width-input :deep(.el-input-number .el-input__wrapper) {
  padding-left: 6px;
  padding-right: 6px;
}

@media (max-width: 960px) {
  .style-row-4 {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 520px) {
  .style-row-4 {
    grid-template-columns: minmax(0, 1fr);
  }
}

.field--show-grid {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
}

.field--show-grid :deep(.el-switch) {
  min-height: 32px;
}

.field-bubble-breaks__control-row {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.field--bubble-breaks .field-bubble-breaks__control-row :deep(.el-input) {
  flex: 1 1 auto;
  min-width: 0;
}

.bubble-breaks-help-chip {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
  height: 26px;
  padding: 0 9px 0 8px;
  margin: 0;
  border: 1px solid rgba(91, 140, 122, 0.22);
  border-radius: 999px;
  cursor: pointer;
  font-family: inherit;
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.02em;
  color: #5f756d;
  background: rgba(255, 255, 255, 0.75);
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.6) inset;
  transition:
    background 0.15s ease,
    border-color 0.15s ease,
    color 0.15s ease;
}

.bubble-breaks-help-chip:hover {
  color: #4a6358;
  background: rgba(245, 250, 247, 0.95);
  border-color: rgba(91, 140, 122, 0.35);
}

.bubble-breaks-help-chip:active {
  background: rgba(236, 244, 239, 0.98);
  border-color: rgba(91, 140, 122, 0.4);
}

.bubble-breaks-help-chip:focus-visible {
  outline: 2px solid rgba(91, 140, 122, 0.35);
  outline-offset: 1px;
}

.bubble-breaks-help-chip__icon {
  width: 13px;
  height: 13px;
  flex-shrink: 0;
  color: #6a8f7c;
  opacity: 0.88;
}

.bubble-breaks-help-chip:hover .bubble-breaks-help-chip__icon {
  color: #5b8c7a;
  opacity: 1;
}

.bubble-breaks-help-chip__text {
  line-height: 1;
  white-space: nowrap;
}

.field--bubble-breaks :deep(.el-input__wrapper) {
  padding: 4px 10px;
}

.field--bubble-breaks :deep(.el-input__inner) {
  font-size: 15px;
}

@media (max-width: 720px) {
  .style-grid--cols-3 {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }

  .style-grid--numeric-params {
    grid-template-columns: minmax(0, 1fr);
  }

  .style-grid--numeric-params > .field--bubble-breaks {
    grid-column: auto;
  }

  .style-grid--bubble-size-row.style-grid--numeric-params {
    grid-template-columns: minmax(0, 1fr);
  }

  .style-grid--params-4col,
  .style-grid--params-3col {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

.style-card .field label {
  display: block;
  font-weight: 600;
  color: #4a5c52;
  margin-bottom: 6px;
  line-height: 1.35;
}

.color-row {
  display: flex;
  gap: 8px;
  align-items: center;
}

.style-card .color-row {
  gap: 6px;
}

.style-card :deep(.el-input__wrapper),
.style-card :deep(.el-select .el-input__wrapper),
.style-card :deep(.el-input-number .el-input__wrapper) {
  background-color: rgba(255, 255, 255, 0.92);
  box-shadow: 0 0 0 1px rgba(91, 140, 122, 0.14) inset;
  border-radius: 8px;
  transition: box-shadow 0.2s ease, background 0.2s ease;
}

.style-card :deep(.el-input__wrapper:hover),
.style-card :deep(.el-select:hover .el-input__wrapper),
.style-card :deep(.el-input-number:hover .el-input__wrapper) {
  box-shadow: 0 0 0 1px rgba(91, 140, 122, 0.3) inset;
}

.style-card :deep(.el-input__wrapper.is-focus),
.style-card :deep(.el-select .el-input__wrapper.is-focus),
.style-card :deep(.el-input-number .el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1px #5b8c7a inset, 0 0 0 3px rgba(91, 140, 122, 0.12);
}

.style-card :deep(.el-input-number) {
  width: 100%;
}

.style-card :deep(.el-input-number .el-input-number__decrease),
.style-card :deep(.el-input-number .el-input-number__increase) {
  width: 26px;
  font-size: 14px;
  background: rgba(245, 250, 247, 0.95);
  border-color: rgba(91, 140, 122, 0.14);
  color: #4a7c62;
}

.style-card :deep(.el-input-number .el-input-number__decrease:hover),
.style-card :deep(.el-input-number .el-input-number__increase:hover) {
  color: #2d6b47;
  background: rgba(91, 140, 122, 0.12);
}

.style-card :deep(.el-input-number .el-input-number__decrease.is-disabled),
.style-card :deep(.el-input-number .el-input-number__increase.is-disabled) {
  color: #b0c4b8;
}

.style-card :deep(.el-color-picker__trigger) {
  border-radius: 8px;
  border: 1px solid rgba(91, 140, 122, 0.22);
  padding: 2px;
  box-shadow: 0 1px 3px rgba(45, 90, 65, 0.06);
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.style-card :deep(.el-color-picker__trigger:hover) {
  border-color: rgba(91, 140, 122, 0.4);
}

.format-preview-message {
  margin: 0;
  padding: 12px 14px;
  font-size: 14px;
  line-height: 1.55;
  color: #4a5c52;
  background: rgba(255, 255, 255, 0.88);
  border: 1px solid rgba(91, 140, 122, 0.12);
  border-radius: 12px;
}

.format-preview-note {
  margin: 0 0 10px;
  font-size: 12px;
  line-height: 1.45;
}

.format-preview-table-wrap {
  border-radius: 12px;
  border: 1px solid rgba(91, 140, 122, 0.12);
  overflow: hidden;
  background: rgba(255, 255, 255, 0.88);
}

.format-preview-table {
  width: 100%;
}

.format-preview-table :deep(.el-table__header th) {
  background: rgba(91, 140, 122, 0.08);
  color: #3d5c4a;
  font-weight: 700;
}

.format-preview-table :deep(.el-table__body td) {
  font-size: 13px;
}

.plot-params-read-hint {
  margin: 0 0 10px;
  font-size: 13px;
  line-height: 1.45;
}

.plot-params-read-empty {
  margin: 0;
  font-size: 14px;
}

.plot-params-read-dl dd {
  word-break: break-word;
}
</style>

<style>
.el-popper.grid-style-popover {
  padding: 10px 12px !important;
  border-radius: 10px !important;
  border: 1px solid rgba(91, 140, 122, 0.28) !important;
  background: rgba(252, 254, 253, 0.98) !important;
  box-shadow: 0 12px 32px rgba(35, 55, 40, 0.14) !important;
}

/* 弹窗 teleport 到 body，与主界面「绿系卡片」风格统一 */
.el-dialog.platform-dialog {
  border-radius: 16px;
  border: 1px solid rgba(91, 140, 122, 0.26);
  box-shadow:
    0 22px 56px rgba(35, 55, 40, 0.12),
    0 2px 10px rgba(0, 0, 0, 0.04);
  background: linear-gradient(180deg, #f9fdfb 0%, #ffffff 42%);
  overflow: hidden;
}

.el-dialog.platform-dialog .el-dialog__header {
  padding: 16px 20px 12px;
  margin-right: 0;
  border-bottom: 1px solid rgba(91, 140, 122, 0.14);
  background: linear-gradient(120deg, rgba(228, 241, 234, 0.75) 0%, rgba(255, 255, 255, 0.55) 100%);
}

.el-dialog.platform-dialog .el-dialog__title {
  font-size: 17px;
  font-weight: 700;
  letter-spacing: 0.02em;
  color: #2d5244;
  line-height: 1.35;
}

.el-dialog.platform-dialog .el-dialog__headerbtn {
  top: 12px;
  right: 10px;
  width: 36px;
  height: 36px;
  border-radius: 10px;
  transition: background 0.2s ease, color 0.2s ease;
}

.el-dialog.platform-dialog .el-dialog__headerbtn:hover {
  background: rgba(91, 140, 122, 0.14);
}

.el-dialog.platform-dialog .el-dialog__headerbtn .el-dialog__close {
  color: #4a6b5a;
  font-size: 18px;
}

.el-dialog.platform-dialog .el-dialog__body {
  padding: 16px 20px 10px;
  color: #2b3530;
}

.el-dialog.platform-dialog .muted {
  color: #5c6f65;
}

.el-dialog.platform-dialog .el-dialog__footer {
  padding: 14px 20px 18px;
  border-top: 1px dashed rgba(91, 140, 122, 0.22);
  background: rgba(246, 251, 248, 0.75);
}

.el-dialog.platform-dialog .el-dialog__footer .el-button--primary {
  border-radius: 10px;
  font-weight: 600;
  padding: 9px 20px;
  border: none;
  background: linear-gradient(135deg, #4a7c62 0%, #5b8c7a 42%, #6fa888 100%);
  box-shadow: 0 3px 12px rgba(45, 107, 71, 0.22);
}

.el-dialog.platform-dialog .el-dialog__footer .el-button--primary:hover {
  filter: brightness(1.04);
}

.el-dialog.platform-dialog .el-dialog__footer .el-button--default {
  border-radius: 10px;
  font-weight: 600;
}

.el-dialog.platform-dialog .plot-confirm-params-scroll,
.el-dialog.platform-dialog .pathway-detail-dl {
  background: rgba(255, 255, 255, 0.82);
  padding: 12px 14px;
  border-radius: 12px;
  border: 1px solid rgba(91, 140, 122, 0.12);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.6);
}

.el-dialog.platform-dialog .plot-confirm-params-scroll {
  max-height: min(48vh, 380px);
  overflow-y: auto;
  overflow-x: hidden;
  overscroll-behavior: contain;
  scrollbar-gutter: stable;
}

.el-dialog.platform-dialog .plot-confirm-params-scroll::-webkit-scrollbar {
  width: 8px;
}

.el-dialog.platform-dialog .plot-confirm-params-scroll::-webkit-scrollbar-thumb {
  background: rgba(91, 140, 122, 0.35);
  border-radius: 4px;
}

.el-dialog.platform-dialog .plot-confirm-params-scroll::-webkit-scrollbar-thumb:hover {
  background: rgba(91, 140, 122, 0.5);
}

.el-dialog.platform-dialog.plot-confirm-dialog .el-dialog__header {
  cursor: move;
  user-select: none;
}

.el-dialog.platform-dialog.format-preview-dialog .el-dialog__body {
  padding-top: 8px;
}
</style>

<style>
/* el-popover teleported 到 body，须非 scoped */
.bubble-breaks-help-popper.el-popover.el-popper {
  max-width: min(440px, calc(100vw - 24px));
  padding: 12px 14px 14px;
  border-radius: 12px;
  border: 1px solid rgba(91, 140, 122, 0.22);
  box-shadow: 0 8px 28px rgba(45, 82, 68, 0.12);
  background: linear-gradient(180deg, #fbfffc 0%, #f6faf7 100%);
}

.bubble-breaks-help-popper .bubble-breaks-help__title {
  margin: 0 0 10px;
  font-size: 15px;
  font-weight: 700;
  color: #2d5244;
  letter-spacing: 0.02em;
}

.bubble-breaks-help-popper .bubble-breaks-help__sub {
  margin: 10px 0 4px;
  font-size: 13px;
  font-weight: 700;
  color: #3d5c4d;
}

.bubble-breaks-help-popper .bubble-breaks-help__body {
  margin: 0;
  font-size: 13px;
  line-height: 1.55;
  color: #4a5c52;
}

.bubble-breaks-help-popper .bubble-breaks-help__note {
  margin: 12px 0 0;
  padding-top: 10px;
  border-top: 1px dashed rgba(91, 140, 122, 0.28);
  font-size: 12px;
  line-height: 1.45;
  color: #5a6b62;
}
</style>
