<template>
  <el-row>
    <el-col :span="20" :offset="2">
      <div class="container flag-container">
        <el-dialog :title="$t('flag.deleteFlagTitle')" :visible.sync="dialogDeleteFlagVisible">
          <span>{{ $t('flag.deleteFlagMessage') }}</span>
          <span slot="footer" class="dialog-footer">
            <el-button @click="dialogDeleteFlagVisible = false">{{ $t('home.cancel') }}</el-button>
            <el-button type="primary" @click.prevent="deleteFlag">{{ $t('flag.confirm') }}</el-button>
          </span>
        </el-dialog>

        <el-dialog :title="$t('flag.editDistributionTitle')" :visible.sync="dialogEditDistributionOpen">
          <div v-if="loaded && flag">
            <div v-for="variant in flag.variants" :key="'distribution-variant-' + variant.id">
              <div>
                <el-checkbox
                  @change="(e) => selectVariant(e, variant)"
                  :checked="!!newDistributions[variant.id]"
                ></el-checkbox>
                <el-tag type="danger" :disable-transitions="true">{{ variant.key }}</el-tag>
              </div>
              <el-slider
                v-if="!newDistributions[variant.id]"
                :value="0"
                :disabled="true"
                show-input
              ></el-slider>
              <div v-if="!!newDistributions[variant.id]">
                <el-slider
                  v-model="newDistributions[variant.id].percent"
                  :disabled="false"
                  show-input
                ></el-slider>
              </div>
            </div>
          </div>
          <el-button
            class="width--full"
            :disabled="!newDistributionIsValid"
            @click.prevent="() => saveDistribution(selectedSegment)"
          >{{ $t('flag.save') }}</el-button>

          <el-alert
            class="edit-distribution-alert"
            v-if="!newDistributionIsValid"
            :title="
              $t('flag.percentagesError', { percent: newDistributionPercentageSum })
            "
            type="error"
            show-icon
          ></el-alert>
        </el-dialog>

        <el-dialog :title="$t('flag.createSegmentTitle')" :visible.sync="dialogCreateSegmentOpen">
          <div>
            <p>
              <el-input :placeholder="$t('flag.segmentDescriptionPlaceholder')" v-model="newSegment.description"></el-input>
            </p>
            <p>
              <el-slider v-model="newSegment.rolloutPercent" show-input></el-slider>
            </p>
            <el-button
              class="width--full"
              :disabled="!newSegment.description"
              @click.prevent="createSegment"
            >{{ $t('flag.createSegment') }}</el-button>
          </div>
        </el-dialog>

        <el-breadcrumb separator="/">
          <el-breadcrumb-item :to="{ name: 'home' }">{{ $t('flag.breadcrumbHome') }}</el-breadcrumb-item>
          <el-breadcrumb-item>{{ $t('flag.breadcrumbFlagId', { id: $route.params.flagId }) }}</el-breadcrumb-item>
        </el-breadcrumb>

        <div v-if="loaded && flag">
          <el-tabs @tab-click="handleHistoryTabClick">
            <el-tab-pane :label="$t('flag.configTab')">
              <el-card class="flag-config-card">
                <div slot="header" class="el-card-header">
                  <div class="flex-row">
                    <div class="flex-row-left">
                      <h2>{{ $t('flag.flag') }}</h2>
                    </div>
                    <div class="flex-row-right" v-if="flag">
                      <el-tooltip :content="$t('flag.enableDisableTooltip')" placement="top" effect="light">
                        <el-switch
                          v-model="flag.enabled"
                          active-color="#13ce66"
                          inactive-color="#ff4949"
                          @change="setFlagEnabled"
                          :active-value="true"
                          :inactive-value="false"
                        ></el-switch>
                      </el-tooltip>
                    </div>
                  </div>
                </div>
                <el-card shadow="hover" :class="toggleInnerConfigCard">
                  <div class="flex-row id-row">
                    <div class="flex-row-left">
                      <el-tag
                        type="primary"
                        :disable-transitions="true"
                      >{{ $t('flag.breadcrumbFlagId', { id: $route.params.flagId }) }}</el-tag>
                    </div>
                    <div class="flex-row-right">
                      <el-button size="small" @click="putFlag(flag)">{{ $t('flag.saveFlag') }}</el-button>
                    </div>
                  </div>
                  <el-row class="flag-content" type="flex" align="middle">
                    <el-col :span="17">
                      <el-row>
                        <el-col :span="24">
                          <el-input size="small" :placeholder="$t('flag.keyPlaceholder')" v-model="flag.key">
                            <template slot="prepend">{{ $t('flag.flagKey') }}</template>
                          </el-input>
                        </el-col>
                      </el-row>
                    </el-col>
                    <el-col style="text-align: right;" :span="5">
                      <div>
                        <el-switch
                          size="small"
                          v-model="flag.dataRecordsEnabled"
                          active-color="#74E5E0"
                          :active-value="true"
                          :inactive-value="false"
                        ></el-switch>
                      </div>
                    </el-col>
                    <el-col :span="2">
                      <div class="data-records-label">
                        {{ $t('flag.dataRecords') }}
                        <el-tooltip
                          :content="$t('flag.dataRecordsTooltip')"
                          placement="top-end"
                          effect="light"
                        >
                          <span class="el-icon-info" />
                        </el-tooltip>
                      </div>
                    </el-col>
                  </el-row>
                  <el-row class="flag-content" type="flex" align="middle">
                    <el-col :span="17">
                      <el-row>
                        <el-col :span="24">
                          <el-input
                            size="small"
                            :placeholder="$t('flag.descriptionPlaceholder')"
                            v-model="flag.description"
                          >
                            <template slot="prepend">{{ $t('flag.flagDescription') }}</template>
                          </el-input>
                        </el-col>
                      </el-row>
                    </el-col>
                    <el-col style="text-align: right;" :span="5">
                      <div>
                        <el-select
                          v-show="!!flag.dataRecordsEnabled"
                          v-model="flag.entityType"
                          size="mini"
                          filterable
                          :allow-create="allowCreateEntityType"
                          default-first-option
                          placeholder="<null>"
                        >
                          <el-option
                            v-for="item in entityTypes"
                            :key="item.value"
                            :label="item.label"
                            :value="item.value"
                          ></el-option>
                        </el-select>
                      </div>
                    </el-col>
                    <el-col :span="2">
                      <div v-show="!!flag.dataRecordsEnabled" class="data-records-label">
                        {{ $t('flag.entityType') }}
                        <el-tooltip
                          :content="$t('flag.entityTypeTooltip')"
                          placement="top-end"
                          effect="light"
                        >
                          <span class="el-icon-info" />
                        </el-tooltip>
                      </div>
                    </el-col>
                  </el-row>
                  <el-row style="margin: 10px;">
                    <h5>
                      <span style="margin-right: 10px;">{{ $t('flag.flagNotes') }}</span>
                      <el-button round size="mini" @click="toggleShowMdEditor">
                        <span :class="editViewIcon"></span>
                        {{ !this.showMdEditor ? $t('flag.edit') : $t('flag.view') }}
                      </el-button>
                    </h5>
                  </el-row>
                  <el-row>
                    <markdown-editor
                      :showEditor="this.showMdEditor"
                      :markdown.sync="flag.notes"
                      @save="putFlag(flag)"
                    ></markdown-editor>
                  </el-row>
                  <el-row style="margin: 10px;">
                    <h5>
                      <span style="margin-right: 10px;">{{ $t('flag.tags') }}</span>
                    </h5>
                  </el-row>
                  <el-row>
                    <div class="tags-container-inner">
                      <el-tag
                        v-for="tag in flag.tags"
                        :key="tag.id"
                        closable
                        :type="warning"
                        @close="deleteTag(tag)"
                      >{{tag.value}}</el-tag>
                      <el-autocomplete
                        class="tag-key-input"
                        v-if="tagInputVisible"
                        v-model="newTag.value"
                        ref="saveTagInput"
                        size="mini"
                        :trigger-on-focus="false"
                        :fetch-suggestions="queryTags"
                        @select="createTag"
                        @keyup.enter.native="createTag"
                        @keyup.esc.native="cancelCreateTag"
                      ></el-autocomplete>
                      <el-button
                        v-else
                        class="button-new-tag"
                        size="small"
                        @click="showTagInput"
                      >{{ $t('flag.newTag') }}</el-button>
                    </div>
                  </el-row>
                </el-card>
              </el-card>

              <el-card class="variants-container">
                <div slot="header" class="clearfix">
                  <h2>{{ $t('flag.variants') }}</h2>
                </div>
                <div class="variants-container-inner" v-if="flag.variants.length">
                  <div v-for="variant in flag.variants" :key="variant.id">
                    <el-card shadow="hover">
                      <el-form label-position="left" label-width="100px">
                        <div class="flex-row id-row">
                          <el-tag type="primary" :disable-transitions="true">
                            {{ $t('flag.variantId') }}
                            <b>{{ variant.id }}</b>
                          </el-tag>
                          <el-input
                            class="variant-key-input"
                            size="small"
                            :placeholder="$t('flag.keyPlaceholder')"
                            v-model="variant.key"
                          >
                            <template slot="prepend">{{ $t('flag.key') }}</template>
                          </el-input>
                          <div class="flex-row-right save-remove-variant-row">
                            <el-button
                              slot="append"
                              size="small"
                              @click="putVariant(variant)"
                            >{{ $t('flag.saveVariant') }}</el-button>
                            <el-button @click="deleteVariant(variant)" size="small">
                              <span class="el-icon-delete" />
                            </el-button>
                          </div>
                        </div>
                        <el-collapse class="flex-row">
                          <el-collapse-item
                            :title="$t('flag.variantAttachment')"
                            class="variant-attachment-collapsable-title"
                          >
                            <p
                              class="variant-attachment-title"
                            >{{ $t('flag.variantAttachmentTitle') }}</p>
                            <vue-json-editor
                              v-model="variant.attachment"
                              :showBtns="false"
                              :mode="'code'"
                              v-on:has-error="variant.attachmentValid = false"
                              v-on:input="variant.attachmentValid = true"
                              class="variant-attachment-content"
                            ></vue-json-editor>
                          </el-collapse-item>
                        </el-collapse>
                      </el-form>
                    </el-card>
                  </div>
                </div>
                <div class="card--error" v-else>{{ $t('flag.noVariants') }}</div>
                <div class="variants-input">
                  <div class="flex-row equal-width constraints-inputs-container">
                    <div>
                      <el-input :placeholder="$t('flag.variantKeyPlaceholder')" v-model="newVariant.key"></el-input>
                    </div>
                  </div>
                  <el-button
                    class="width--full"
                    :disabled="!newVariant.key"
                    @click.prevent="createVariant"
                  >{{ $t('flag.createVariant') }}</el-button>
                </div>
              </el-card>

              <el-card class="segments-container">
                <div slot="header" class="el-card-header">
                  <div class="flex-row">
                    <div class="flex-row-left">
                      <h2>{{ $t('flag.segments') }}</h2>
                    </div>
                    <div class="flex-row-right">
                      <el-tooltip
                        :content="$t('flag.reorderTooltip')"
                        placement="top"
                        effect="light"
                      >
                        <el-button @click="putSegmentsReorder(flag.segments)">{{ $t('flag.reorder') }}</el-button>
                      </el-tooltip>
                      <el-button @click="dialogCreateSegmentOpen = true">{{ $t('flag.newSegment') }}</el-button>
                    </div>
                  </div>
                </div>
                <div class="segments-container-inner" v-if="flag.segments.length">
                  <draggable v-model="flag.segments" @start="drag = true" @end="drag = false">
                    <transition-group>
                      <el-card
                        shadow="hover"
                        v-for="segment in flag.segments"
                        :key="segment.id"
                        class="segment grabbable"
                      >
                        <div class="flex-row id-row">
                          <div class="flex-row-left">
                            <el-tag type="primary" :disable-transitions="true">
                              {{ $t('flag.segmentId') }}
                              <b>{{ segment.id }}</b>
                            </el-tag>
                          </div>
                          <div class="flex-row-right">
                            <el-button
                              slot="append"
                              size="small"
                              @click="putSegment(segment)"
                            >{{ $t('flag.saveSegmentSetting') }}</el-button>
                            <el-button @click="deleteSegment(segment)" size="small">
                              <span class="el-icon-delete" />
                            </el-button>
                          </div>
                        </div>
                        <el-row :gutter="10" class="id-row">
                          <el-col :span="15">
                            <el-input
                              size="small"
                              :placeholder="$t('flag.descriptionPlaceholder')"
                              v-model="segment.description"
                            >
                              <template slot="prepend">{{ $t('flag.segmentDescription') }}</template>
                            </el-input>
                          </el-col>
                          <el-col :span="9">
                            <el-input
                              class="segment-rollout-percent"
                              size="small"
                              placeholder="0"
                              v-model="segment.rolloutPercent"
                              :min="0"
                              :max="100"
                            >
                              <template slot="prepend">{{ $t('flag.rollout') }}</template>
                              <template slot="append">%</template>
                            </el-input>
                          </el-col>
                        </el-row>
                        <el-row>
                          <el-col :span="24">
                            <h5>{{ $t('flag.constraints') }}</h5>
                            <div class="constraints">
                              <div class="constraints-inner" v-if="segment.constraints.length">
                                <div v-for="constraint in segment.constraints" :key="constraint.id">
                                  <el-row :gutter="3" class="segment-constraint">
                                    <el-col :span="20">
                                      <el-input
                                        size="small"
                                        :placeholder="$t('flag.property')"
                                        v-model="constraint.property"
                                      >
                                        <template slot="prepend">{{ $t('flag.property') }}</template>
                                      </el-input>
                                    </el-col>
                                    <el-col :span="4">
                                      <el-select
                                        class="width--full"
                                        size="small"
                                        v-model="constraint.operator"
                                        :placeholder="$t('flag.operator')"
                                      >
                                        <el-option
                                          v-for="item in operatorOptions"
                                          :key="item.value"
                                          :label="item.label"
                                          :value="item.value"
                                        ></el-option>
                                      </el-select>
                                    </el-col>
                                    <el-col :span="20">
                                      <el-input size="small" v-model="constraint.value">
                                        <template slot="prepend">{{ $t('flag.value') }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</template>
                                      </el-input>
                                    </el-col>
                                    <el-col :span="2">
                                      <el-button
                                        type="success"
                                        plain
                                        class="width--full"
                                        @click="
                                          putConstraint(segment, constraint)
                                        "
                                        size="small"
                                      >{{ $t('flag.save') }}</el-button>
                                    </el-col>
                                    <el-col :span="2">
                                      <el-button
                                        type="danger"
                                        plain
                                        class="width--full"
                                        @click="
                                          deleteConstraint(segment, constraint)
                                        "
                                        size="small"
                                      >
                                        <i class="el-icon-delete"></i>
                                      </el-button>
                                    </el-col>
                                  </el-row>
                                </div>
                              </div>
                              <div class="card--empty" v-else>
                                <span>{{ $t('flag.noConstraints') }}</span>
                              </div>
                              <div>
                                <el-row :gutter="3">
                                  <el-col :span="5">
                                    <el-input
                                      size="small"
                                      :placeholder="$t('flag.property')"
                                      v-model="segment.newConstraint.property"
                                    ></el-input>
                                  </el-col>
                                  <el-col :span="4">
                                    <el-select
                                      size="small"
                                      v-model="segment.newConstraint.operator"
                                      :placeholder="$t('flag.operator')"
                                    >
                                      <el-option
                                        v-for="item in operatorOptions"
                                        :key="item.value"
                                        :label="item.label"
                                        :value="item.value"
                                      ></el-option>
                                    </el-select>
                                  </el-col>
                                  <el-col :span="11">
                                    <el-input size="small" v-model="segment.newConstraint.value"></el-input>
                                  </el-col>
                                  <el-col :span="4">
                                    <el-button
                                      class="width--full"
                                      size="small"
                                      type="primary"
                                      plain
                                      :disabled="
                                        !segment.newConstraint.property ||
                                        !segment.newConstraint.value
                                      "
                                      @click.prevent="
                                        () => createConstraint(segment)
                                      "
                                    >{{ $t('flag.addConstraint') }}</el-button>
                                  </el-col>
                                </el-row>
                              </div>
                            </div>
                          </el-col>
                          <el-col :span="24" class="segment-distributions">
                            <h5>
                              <span>{{ $t('flag.distribution') }}</span>
                              <el-button round size="mini" @click="editDistribution(segment)">
                                <span class="el-icon-edit"></span> {{ $t('flag.edit') }}
                              </el-button>
                            </h5>
                            <el-row type="flex" v-if="segment.distributions.length" :gutter="20">
                              <el-col
                                v-for="distribution in segment.distributions"
                                :key="distribution.id"
                                :span="6"
                              >
                                <el-card shadow="never" class="distribution-card">
                                  <div>
                                    <span size="small">
                                      {{
                                      distribution.variantKey
                                      }}
                                    </span>
                                  </div>
                                  <el-progress
                                    type="circle"
                                    color="#74E5E0"
                                    :width="70"
                                    :percentage="distribution.percent"
                                  ></el-progress>
                                </el-card>
                              </el-col>
                            </el-row>

                            <div class="card--error" v-else>{{ $t('flag.noDistribution') }}</div>
                          </el-col>
                        </el-row>
                      </el-card>
                    </transition-group>
                  </draggable>
                </div>
                <div class="card--error" v-else>{{ $t('flag.noSegments') }}</div>
              </el-card>
              <debug-console :flag="this.flag"></debug-console>
              <el-card>
                <div slot="header" class="el-card-header">
                  <h2>{{ $t('flag.flagSettings') }}</h2>
                </div>
                <el-button @click="dialogDeleteFlagVisible = true" type="danger" plain>
                  <span class="el-icon-delete"></span>
                  {{ $t('flag.deleteFlag') }}
                </el-button>
              </el-card>
              <spinner v-if="!loaded"></spinner>
            </el-tab-pane>

            <el-tab-pane :label="$t('flag.historyTab')">
              <flag-history v-if="historyLoaded" :flag-id="parseInt($route.params.flagId, 10)"></flag-history>
            </el-tab-pane>
          </el-tabs>
        </div>
      </div>
    </el-col>
  </el-row>
</template>

<script>
import clone from "lodash.clone";
import draggable from "vuedraggable";
import Axios from "axios";

import constants from "@/constants";
import helpers from "@/helpers/helpers";
import Spinner from "@/components/Spinner";
import DebugConsole from "@/components/DebugConsole";
import FlagHistory from "@/components/FlagHistory";
import MarkdownEditor from "@/components/MarkdownEditor.vue";
import vueJsonEditor from "vue-json-editor";
import { operators } from "@/operators.json";

const OPERATOR_VALUE_TO_LABEL_MAP = operators.reduce((acc, el) => {
  acc[el.value] = el.label;
  return acc;
}, {});

const { sum, pluck, handleErr } = helpers;

const { API_URL, FLAGR_UI_POSSIBLE_ENTITY_TYPES } = constants;

const DEFAULT_SEGMENT = {
  description: "",
  rolloutPercent: 50
};

const DEFAULT_CONSTRAINT = {
  operator: "EQ",
  property: "",
  value: ""
};

const DEFAULT_VARIANT = {
  key: ""
};

const DEFAULT_TAG = {
  value: ""
};

const DEFAULT_DISTRIBUTION = {
  bitmap: "",
  variantID: 0,
  variantKey: "",
  percent: 0
};

function processSegment(segment) {
  segment.newConstraint = clone(DEFAULT_CONSTRAINT);
}

function processVariant(variant) {
  if (typeof variant.attachment === "string") {
    variant.attachment = JSON.parse(variant.attachment);
  }
}

export default {
  name: "flag",
  components: {
    spinner: Spinner,
    debugConsole: DebugConsole,
    flagHistory: FlagHistory,
    draggable: draggable,
    MarkdownEditor,
    vueJsonEditor
  },
  data() {
    return {
      loaded: false,
      dialogDeleteFlagVisible: false,
      dialogEditDistributionOpen: false,
      dialogCreateSegmentOpen: false,
      entityTypes: [],
      allTags: [],
      allowCreateEntityType: true,
      tagInputVisible: false,
      flag: {
        createdBy: "",
        dataRecordsEnabled: false,
        entityType: "",
        description: "",
        enabled: false,
        id: 0,
        key: "",
        tags: [],
        segments: [],
        updatedAt: "",
        variants: [],
        notes: ""
      },
      newSegment: clone(DEFAULT_SEGMENT),
      newVariant: clone(DEFAULT_VARIANT),
      newTag: clone(DEFAULT_TAG),
      selectedSegment: null,
      newDistributions: {},
      operatorOptions: operators,
      operatorValueToLabelMap: OPERATOR_VALUE_TO_LABEL_MAP,
      showMdEditor: false,
      historyLoaded: false
    };
  },
  computed: {
    newDistributionPercentageSum() {
      return sum(pluck(Object.values(this.newDistributions), "percent"));
    },
    newDistributionIsValid() {
      const percentageSum = sum(
        pluck(Object.values(this.newDistributions), "percent")
      );
      return percentageSum === 100;
    },
    flagId() {
      return this.$route.params.flagId;
    },
    editViewIcon() {
      return {
        "el-icon-edit": !this.showMdEditor,
        "el-icon-view": this.showMdEditor
      };
    },
    toggleInnerConfigCard() {
      if (!this.showMdEditor && !this.flag.notes) {
        return "flag-inner-config-card";
      } else {
        return "";
      }
    }
  },
  methods: {
    deleteFlag() {
      const flagId = this.flagId;
      Axios.delete(`${API_URL}/flags/${this.flagId}`).then(() => {
        this.$router.replace({ name: "home" });
        this.$message.success(this.$t('flag.flagDeleted', { id: flagId }));
      }, handleErr.bind(this));
    },
    putFlag(flag) {
      Axios.put(`${API_URL}/flags/${this.flagId}`, {
        description: flag.description,
        dataRecordsEnabled: flag.dataRecordsEnabled,
        key: flag.key || "",
        entityType: flag.entityType || "",
        notes: flag.notes || ""
      }).then(() => {
        this.$message.success(this.$t('home.flagUpdated'));
      }, handleErr.bind(this));
    },
    setFlagEnabled(checked) {
      Axios.put(`${API_URL}/flags/${this.flagId}/enabled`, {
        enabled: checked
      }).then(() => {
        const msg = checked ? this.$t('flag.flagEnabledOn') : this.$t('flag.flagEnabledOff');
        this.$message.success(msg);
      }, handleErr.bind(this));
    },
    selectVariant($event, variant) {
      const checked = $event;
      if (checked) {
        const distribution = Object.assign(clone(DEFAULT_DISTRIBUTION), {
          variantKey: variant.key,
          variantID: variant.id
        });
        this.$set(this.newDistributions, variant.id, distribution);
      } else {
        this.$delete(this.newDistributions, variant.id);
      }
    },
    editDistribution(segment) {
      this.selectedSegment = segment;

      this.$set(this, "newDistributions", {});

      segment.distributions.forEach(distribution => {
        this.$set(
          this.newDistributions,
          distribution.variantID,
          clone(distribution)
        );
      });

      this.dialogEditDistributionOpen = true;
    },
    saveDistribution(segment) {
      const distributions = Object.values(this.newDistributions).filter(
        distribution => distribution.percent !== 0
      ).map(distribution => {
        let dist = clone(distribution)
        delete dist.id;
        return dist
      });

      Axios.put(
        `${API_URL}/flags/${this.flagId}/segments/${segment.id}/distributions`,
        { distributions }
      ).then(response => {
        let distributions = response.data;
        this.selectedSegment.distributions = distributions;
        this.dialogEditDistributionOpen = false;
        this.$message.success(this.$t('flag.distributionsUpdated'));
      }, handleErr.bind(this));
    },
    createVariant() {
      Axios.post(
        `${API_URL}/flags/${this.flagId}/variants`,
        this.newVariant
      ).then(response => {
        let variant = response.data;
        this.newVariant = clone(DEFAULT_VARIANT);
        this.flag.variants.push(variant);
        this.$message.success(this.$t('flag.newVariantCreated'));
      }, handleErr.bind(this));
    },
    deleteVariant(variant) {
      const isVariantInUse = this.flag.segments.some(segment =>
        segment.distributions.some(
          distribution => distribution.variantID === variant.id
        )
      );

      if (isVariantInUse) {
        alert(this.$t('flag.variantInUse'));
        return;
      }

      if (
        !confirm(
          this.$t('flag.deleteVariantConfirm', { id: variant.id, key: variant.key })
        )
      ) {
        return;
      }

      Axios.delete(
        `${API_URL}/flags/${this.flagId}/variants/${variant.id}`
      ).then(() => {
        this.$message.success(this.$t('flag.variantDeleted'));
        this.fetchFlag();
      }, handleErr.bind(this));
    },
    putVariant(variant) {
      if (variant.attachmentValid === false) {
        this.$message.error(this.$t('flag.variantAttachmentInvalid'));
        return;
      }
      Axios.put(
        `${API_URL}/flags/${this.flagId}/variants/${variant.id}`,
        variant
      ).then(() => {
        this.$message.success(this.$t('flag.variantUpdated'));
      }, handleErr.bind(this));
    },
    createTag() {
      Axios.post(`${API_URL}/flags/${this.flagId}/tags`, this.newTag).then(
        response => {
          let tag = response.data;
          this.newTag = clone(DEFAULT_TAG);
          if (!this.flag.tags.map(tag => tag.value).includes(tag.value)) {
            this.flag.tags.push(tag);
            this.$message.success(this.$t('flag.newTagCreated'));
          }
          this.tagInputVisible = false;
          this.loadAllTags();
        },
        handleErr.bind(this)
      );
    },
    cancelCreateTag() {
      this.newTag = clone(DEFAULT_TAG);
      this.tagInputVisible = false;
    },
    queryTags(queryString, cb) {
      let results = this.allTags.filter(tag =>
        tag.value.toLowerCase().includes(queryString.toLowerCase())
      );
      cb(results);
    },
    loadAllTags() {
      Axios.get(`${API_URL}/tags`).then(response => {
        let result = response.data;
        this.allTags = result;
      }, handleErr.bind(this));
    },
    showTagInput() {
      this.tagInputVisible = true;
      this.$nextTick(() => {
        this.$refs.saveTagInput.$refs.input.focus();
      });
    },
    deleteTag(tag) {
      if (!confirm(this.$t('flag.deleteTagConfirm', { value: tag.value }))) {
        return;
      }

      Axios.delete(`${API_URL}/flags/${this.flagId}/tags/${tag.id}`).then(
        () => {
          this.$message.success(this.$t('flag.tagDeleted'));
          this.fetchFlag();
          this.loadAllTags();
        },
        handleErr.bind(this)
      );
    },
    createConstraint(segment) {
      segment.newConstraint.property = segment.newConstraint.property.trim();
      segment.newConstraint.value = segment.newConstraint.value.trim();
      Axios.post(
        `${API_URL}/flags/${this.flagId}/segments/${segment.id}/constraints`,
        segment.newConstraint
      ).then(response => {
        let constraint = response.data;
        segment.constraints.push(constraint);
        segment.newConstraint = clone(DEFAULT_CONSTRAINT);
        this.$message.success(this.$t('flag.newConstraintCreated'));
      }, handleErr.bind(this));
    },
    putConstraint(segment, constraint) {
      constraint.property = constraint.property.trim();
      constraint.value = constraint.value.trim();
      Axios.put(
        `${API_URL}/flags/${this.flagId}/segments/${segment.id}/constraints/${constraint.id}`,
        constraint
      ).then(() => {
        this.$message.success(this.$t('flag.constraintUpdated'));
      }, handleErr.bind(this));
    },
    deleteConstraint(segment, constraint) {
      if (!confirm(this.$t('flag.deleteConstraintConfirm'))) {
        return;
      }

      Axios.delete(
        `${API_URL}/flags/${this.flagId}/segments/${segment.id}/constraints/${constraint.id}`
      ).then(() => {
        const index = segment.constraints.findIndex(
          c => c.id === constraint.id
        );
        segment.constraints.splice(index, 1);
        this.$message.success(this.$t('flag.constraintDeleted'));
      }, handleErr.bind(this));
    },
    putSegment(segment) {
      Axios.put(`${API_URL}/flags/${this.flagId}/segments/${segment.id}`, {
        description: segment.description,
        rolloutPercent: parseInt(segment.rolloutPercent, 10)
      }).then(() => {
        this.$message.success(this.$t('flag.segmentUpdated'));
      }, handleErr.bind(this));
    },
    putSegmentsReorder(segments) {
      Axios.put(`${API_URL}/flags/${this.flagId}/segments/reorder`, {
        segmentIDs: pluck(segments, "id")
      }).then(() => {
        this.$message.success(this.$t('flag.segmentReordered'));
      }, handleErr.bind(this));
    },
    deleteSegment(segment) {
      if (!confirm(this.$t('flag.deleteSegmentConfirm'))) {
        return;
      }

      Axios.delete(
        `${API_URL}/flags/${this.flagId}/segments/${segment.id}`
      ).then(() => {
        const index = this.flag.segments.findIndex(el => el.id === segment.id);
        this.flag.segments.splice(index, 1);
        this.$message.success(this.$t('flag.segmentDeleted'));
      }, handleErr.bind(this));
    },
    createSegment() {
      Axios.post(
        `${API_URL}/flags/${this.flagId}/segments`,
        this.newSegment
      ).then(response => {
        let segment = response.data;
        processSegment(segment);
        segment.constraints = [];
        this.newSegment = clone(DEFAULT_SEGMENT);
        this.flag.segments.push(segment);
        this.$message.success(this.$t('flag.newSegmentCreated'));
        this.dialogCreateSegmentOpen = false;
      }, handleErr.bind(this));
    },
    fetchFlag() {
      Axios.get(`${API_URL}/flags/${this.flagId}`).then(response => {
        let flag = response.data;
        flag.segments.forEach(segment => processSegment(segment));
        flag.variants.forEach(variant => processVariant(variant));
        this.flag = flag;
        this.loaded = true;
      }, handleErr.bind(this));
      this.fetchEntityTypes();
    },
    fetchEntityTypes() {
      function prepareEntityTypes(entityTypes) {
        let arr = entityTypes.map(key => {
          let label = key === "" ? "<null>" : key;
          return { label: label, value: key };
        });
        if (entityTypes.indexOf("") === -1) {
          arr.unshift({ label: "<null>", value: "" });
        }
        return arr;
      }

      if (
        FLAGR_UI_POSSIBLE_ENTITY_TYPES &&
        FLAGR_UI_POSSIBLE_ENTITY_TYPES != "null"
      ) {
        let entityTypes = FLAGR_UI_POSSIBLE_ENTITY_TYPES.split(",");
        this.entityTypes = prepareEntityTypes(entityTypes);
        this.allowCreateEntityType = false;
        return;
      }

      Axios.get(`${API_URL}/flags/entity_types`).then(response => {
        this.entityTypes = prepareEntityTypes(response.data);
      }, handleErr.bind(this));
    },
    toggleShowMdEditor() {
      this.showMdEditor = !this.showMdEditor;
    },
    handleHistoryTabClick(tab) {
      if (tab.label == this.$t('flag.historyTab') && !this.historyLoaded) {
        this.historyLoaded = true;
      }
    }
  },
  mounted() {
    this.fetchFlag();
    this.loadAllTags();
  }
};
</script>

<style lang="less">
h5 {
  padding: 0;
  margin: 10px 0 5px;
}

.grabbable {
  cursor: move; /* fallback if grab cursor is unsupported */
  cursor: grab;
  cursor: -moz-grab;
  cursor: -webkit-grab;
}

.flag-inner-config-card {
  .el-card__body {
    padding-bottom: 0px;
  }
}

.segment {
  .highlightable {
    padding: 4px;
    &:hover {
      background-color: #ddd;
    }
  }
  .segment-constraint {
    margin-bottom: 12px;
    padding: 1px;
    background-color: #f6f6f6;
    border-radius: 5px;
  }
  .distribution-card {
    height: 110px;
    text-align: center;
    .el-card__body {
      padding: 3px 10px 10px 10px;
    }
    font-size: 0.9em;
  }
}

ol.constraints-inner {
  background-color: white;
  padding-left: 8px;
  padding-right: 8px;
  border-radius: 3px;
  border: 1px solid #ddd;
  li {
    padding: 3px 0;
    .el-tag {
      font-size: 0.7em;
    }
  }
}

.constraints-inputs-container {
  padding: 5px 0;
}

.variants-container-inner {
  .el-card {
    margin-bottom: 1em;
  }
  .el-input-group__prepend {
    width: 2em;
  }
}

.segment-description-rollout {
  margin-top: 10px;
}

.edit-distribution-button {
  margin-top: 5px;
}

.edit-distribution-alert {
  margin-top: 10px;
}

.el-form-item {
  margin-bottom: 5px;
}

.id-row {
  margin-bottom: 8px;
}

.flag-config-card {
  .flag-content {
    margin-top: 8px;
    margin-bottom: -8px;
    .el-input-group__prepend {
      width: 8em;
    }
  }
  .data-records-label {
    margin-left: 3px;
    margin-bottom: 5px;
    margin-top: 6px;
    font-size: 0.65em;
    white-space: nowrap;
    vertical-align: middle;
  }
}

.variant-attachment-collapsable-title {
  margin: 0;
  font-size: 13px;
  color: #909399;
  width: 100%;
}

.variant-attachment-title {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.variant-key-input {
  margin-left: 10px;
  width: 50%;
}

.save-remove-variant-row {
  padding-bottom: 5px;
}

.tag-key-input {
  margin: 2.5px;
  width: 20%;
}

.tags-container-inner {
  margin-bottom: 10px;
}

.button-new-tag {
  margin: 2.5px;
}
</style>