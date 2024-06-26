import { LoginFormModel } from '../../models'
import { login } from '../../api'
import { TOKEN_KEY } from '../../constants'
import router from '@ohos.router'
import { UserSettingClass } from '../../utils'
import promptAction from '@ohos.promptAction'

PersistentStorage.PersistProp(TOKEN_KEY, "")

@Entry
@Component
struct Login {
  @Styles inputStyle() {
    .backgroundColor('#fff')
    .border({ color: $r('app.color.background_divider'), width: { bottom: 1 } })
    .width('100%')
    .height(58)
    .borderRadius(0)
  }

  @State showLoading: boolean = false
  @State accountForm: LoginFormModel = new LoginFormModel({
    account: '',
    password: '',
  })

  // 通过校验
  getFormValidate() {
    if (this.accountForm.password && this.accountForm.account) {
      return true
    }
    // promptAction.showToast({ message: '请输入账号和密码' })
    return false
  }
  // 调用登录接口
  async login() {
    try {
      this.showLoading = true
      const token = await login(this.accountForm)
      AppStorage.Set(TOKEN_KEY, token) // 写入本地缓存
      new UserSettingClass(getContext(this)).setUserToken(token) // 存入首选项
      this.showLoading = false
      router.replaceUrl({
        url: 'pages/Index/Index'
      })
    }catch (error) {

    } finally {
      this.showLoading = false
    }

  }

  build() {
    Column() {
      // 顶部标题
      Text("神领快递").fontColor($r('app.color.text_primary')).fontSize(18).height(25)
      // 账号登录
      Row() {
        Text('账号登录').fontColor($r('app.color.text_primary')).fontSize(24).fontWeight(FontWeight.Bold)
        Row() {
          Text("账号登录").fontColor($r('app.color.primary')).fontSize(16).fontWeight(FontWeight.Bold)
          Image($r("app.media.ic_angle")).width(10).height(10).margin({ left: 5 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 50, bottom: 50 })

      // 用户名输入框
      TextInput({ placeholder: '请输入账号' })
        .inputStyle()
        .onChange(value => {
          this.accountForm.account = value
        })
        .onSubmit(() => {
          if(this.getFormValidate()) {
            this.login()
          }
        })

      // 密码框
      TextInput({ placeholder: '请输入密码' })
        .inputStyle()
        .type(InputType.Password) // 密码框
        .showPasswordIcon(true) // 显示密码按钮
        .onChange(value => {
          this.accountForm.password = value
        })
        .onSubmit(() => {
          if(this.getFormValidate()) {
            this.login()
          }
        })

      Button({ type: ButtonType.Capsule }) {
        Row() {
          if(this.showLoading) {
            // 显示进度条再显示
            LoadingProgress().width(20).height(20).margin({ right: 12 }).color($r('app.color.white'))
          }
          Text('登录').fontColor($r('app.color.white'))
        }
      }

      .backgroundColor(this.getFormValidate() ? $r('app.color.primary') :  $r('app.color.primary_disabled'))
      .width('100%')
      .height(50)
      .margin({ top: 50 })
      .enabled(this.getFormValidate())
      .onClick(() => {
        this.login()
      })
    }
    .padding({ left: 32, right: 32 })
    .margin({ top: 40 })
  }
}