<script setup lang="ts">
import CardPanel from "@/components/CardPanel.vue";
import type { LayoutCard } from "@/types";
import type { UserInstance } from "@/types/user";
import { computed, ref, onMounted } from "vue";
import { t } from "@/lang/i18n";
import BetweenMenus from "@/components/BetweenMenus.vue";
import { useScreen } from "@/hooks/useScreen";
import { arrayFilter } from "@/tools/array";
import { userInfoApiAdvanced, remoteInstances } from "@/services/apis";
import { useLayoutCardTools } from "@/hooks/useCardTools";
import { updateUserInstance, updateUserTags } from "@/services/apis";
import { useSelectInstances } from "@/components/fc";
import { message } from "ant-design-vue";
import { reportErrorMsg } from "@/tools/validator";
import { INSTANCE_STATUS } from "@/types/const";
import type { AntColumnsType, AntTableCell } from "@/types/ant";
import dayjs from "dayjs";
import WarningDialog from "@/components/fc/WarningDialog.vue";
import { useMountComponent } from "@/hooks/useMountComponent";
import { useInstanceTagTips } from "@/hooks/useInstanceTag";
import { TagsOutlined, PlusOutlined } from "@ant-design/icons-vue";

const props = defineProps<{
  card: LayoutCard;
  uuid: string;
}>();

const { isPhone } = useScreen();

const dataSource = ref<UserInstance[]>([]);
const userTags = ref<string[]>([]);
const allTagOptions = ref<string[]>([]);
const newTagInput = ref("");
const { getMetaOrRouteValue } = useLayoutCardTools(props.card);
const userUuid = getMetaOrRouteValue("uuid");

const handleDelete = async (deletedInstance: UserInstance) => {
  try {
    for (let valueKey = 0; valueKey < dataSource.value.length; valueKey++) {
      const instance = dataSource.value[valueKey];
      if (
        deletedInstance.daemonId == instance.daemonId &&
        deletedInstance.instanceUuid == instance.instanceUuid
      ) {
        dataSource.value.splice(valueKey, 1);
        break;
      }
    }
    await saveData();
  } catch (error: any) {
    reportErrorMsg(error);
  }
};

const assignApp = async () => {
  try {
    const selectedInstances = await useSelectInstances(dataSource.value);
    let warningInstances: string[] = [];
    for (const instance of selectedInstances || []) {
      if (typeof instance.config?.docker?.image == "string" && !instance.config?.docker?.image)
        warningInstances.push(instance.nickname);
    }
    if (warningInstances.length > 0) {
      const component = (
        await useMountComponent({
          title: t("TXT_CODE_dd78943e"),
          subTitle: t("TXT_CODE_57e86edb") + warningInstances.join(", "),
          checkText: t("TXT_CODE_19f697f3")
        })
      ).load<InstanceType<typeof WarningDialog>>(WarningDialog);
      await component.openDialog();
    }
    if (selectedInstances) dataSource.value = selectedInstances;
    await saveData();
  } catch (err: any) {
    reportErrorMsg(err);
  }
};

const saveData = async () => {
  try {
    await updateUserInstance().execute({
      data: {
        config: {
          instances: dataSource.value
        },
        uuid: <string>userUuid
      }
    });
    message.success(t("TXT_CODE_d3de39b4"));
    refreshTableData().catch(() => {
      // ignore
    });
  } catch (err: any) {
    reportErrorMsg(err.message);
  }
};

async function refreshTableData() {
  if (userUuid == null) {
    return;
  }
  const rawUserInfo = (
    await userInfoApiAdvanced().execute({
      params: {
        uuid: <string>userUuid,
        advanced: true
      },
      forceRequest: true
    })
  ).value;
  if (!rawUserInfo) {
    return;
  }
  const newDataSource: UserInstance[] = [];
  for (const instance of rawUserInfo.instances) {
    newDataSource.push(instance);
  }
  dataSource.value = newDataSource;
  userTags.value = rawUserInfo.tags || [];
}

// Tag management
const { execute: getInstances, state: instances } = remoteInstances();

const loadAllTags = async () => {
  const allTags = new Set<string>();
  // Collect tags from already loaded instances
  for (const inst of dataSource.value) {
    if (inst.config?.tag) {
      for (const tag of inst.config.tag) {
        allTags.add(tag);
      }
    }
  }
  allTagOptions.value = Array.from(allTags).sort();
};

const addUserTag = async () => {
  const tag = newTagInput.value.trim();
  if (!tag) return;
  if (!userTags.value.includes(tag)) {
    userTags.value.push(tag);
    userTags.value.sort();
  }
  newTagInput.value = "";
  await saveUserTags();
};

const removeUserTag = async (tag: string) => {
  userTags.value = userTags.value.filter((t) => t !== tag);
  await saveUserTags();
};

const saveUserTags = async () => {
  try {
    await updateUserTags().execute({
      data: {
        config: {
          tags: userTags.value
        },
        uuid: <string>userUuid
      }
    });
    message.success(t("TXT_CODE_d3de39b4"));
  } catch (err: any) {
    reportErrorMsg(err.message);
  }
};

onMounted(() => {
  refreshTableData().then(() => loadAllTags());
});

const columns = computed(() => {
  return arrayFilter<AntColumnsType>([
    {
      align: "center",
      title: t("TXT_CODE_b26a0528"),
      dataIndex: "remarks",
      key: "remarks",
      minWidth: 200,
      condition: () => !isPhone.value,
      customRender: (row) => {
        return row.record.hostIp + ` (${row.record.remarks})`;
      }
    },
    {
      align: "center",
      title: t("TXT_CODE_f70badb9"),
      dataIndex: "nickname",
      key: "name",
      minWidth: 200
    },
    {
      align: "center",
      title: t("TXT_CODE_fa920c0"),
      dataIndex: "endTime",
      key: "endTime",
      minWidth: 200,
      condition: () => !isPhone.value,
      customRender: (row: { text: string | number }) => {
        if (Number(row.text) === 0) return t("TXT_CODE_8dfd8b17");
        if (!isNaN(Number(row.text))) return dayjs(Number(row.text)).format("YYYY-MM-DD HH:mm:ss");
        return row.text;
      }
    },
    {
      align: "center",
      title: t("TXT_CODE_3d602459"),
      dataIndex: "status",
      key: "status",
      minWidth: 200,
      customRender: (e: { text: "-1" | "1" | "2" | "3" }) => {
        return INSTANCE_STATUS[e.text] || e.text;
      },
      condition: () => !isPhone.value
    },
    {
      align: "center",
      title: t("TXT_CODE_fe731dfc"),
      key: "operation",
      minWidth: 200,
      scopedSlots: { customRender: "operation" }
    }
  ]);
});
</script>

<template>
  <div style="height: 100%" class="container">
    <a-row v-if="userUuid" :gutter="[24, 24]" style="height: 100%">
      <a-col :span="24">
        <BetweenMenus>
          <template v-if="!isPhone" #left>
            <a-typography-title class="mb-0" :level="4">
              {{ t("TXT_CODE_76d20724") }}
            </a-typography-title>
          </template>
          <template #right>
            <a-button @click="refreshTableData()">
              {{ t("TXT_CODE_b76d94e0") }}
            </a-button>
            <a-button type="primary" @click="assignApp">
              {{ t("TXT_CODE_9393b484") }}
            </a-button>
          </template>
        </BetweenMenus>
      </a-col>

      <!-- Tag-based permission section -->
      <a-col :span="24">
        <CardPanel>
          <template #body>
            <a-typography-title :level="5">
              <TagsOutlined />
              {{ t("TXT_CODE_a2544278") }}
            </a-typography-title>
            <a-typography-paragraph>
              <a-typography-text type="secondary">
                {{ t("TXT_CODE_eaabd222") }}
              </a-typography-text>
            </a-typography-paragraph>
            <div class="tag-container">
              <a-tag
                v-for="tag in userTags"
                :key="tag"
                color="blue"
                closable
                @close="() => removeUserTag(tag)"
              >
                {{ tag }}
              </a-tag>
              <a-input
                v-model:value="newTagInput"
                placeholder="+"
                style="width: 72px; display: inline-block"
                size="small"
                @press-enter="addUserTag"
                @blur="addUserTag"
              />
            </div>
          </template>
        </CardPanel>
      </a-col>

      <a-col :span="24">
        <CardPanel class="h-100">
          <template #body>
            <a-table :scroll="{ x: 'max-content' }" :data-source="dataSource" :columns="columns">
              <template #bodyCell="{ column, record }: AntTableCell">
                <template v-if="column.key === 'operation'">
                  <a-popconfirm :title="t('TXT_CODE_71155575')" @confirm="handleDelete(record)">
                    <a-button danger size="large">
                      {{ t("TXT_CODE_ecbd7449") }}
                    </a-button>
                  </a-popconfirm>
                </template>
              </template>
            </a-table>
          </template>
        </CardPanel>
      </a-col>
    </a-row>
  </div>
</template>

<style lang="scss" scoped>
.search-input {
  transition: all 0.4s;
  text-align: center;
  width: 50%;
}

@media (max-width: 992px) {
  .search-input {
    transition: all 0.4s;
    text-align: center;
    width: 100% !important;
  }
}

.search-input:hover {
  width: 100%;
}

.tag-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}
</style>
