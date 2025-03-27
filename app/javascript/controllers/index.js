// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// 明示的にコントローラーを登録
import TeachingMaterialFormController from "./teaching_material_form_controller"
application.register("teaching-material-form", TeachingMaterialFormController)
