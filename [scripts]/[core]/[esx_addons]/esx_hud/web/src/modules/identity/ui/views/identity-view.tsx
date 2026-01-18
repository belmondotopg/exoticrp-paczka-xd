import { useForm } from "react-hook-form";
import { useVisible } from "@yankes/fivem-react/hooks";
import { fetchNui } from "@yankes/fivem-react/utils";
import { zodResolver } from "@hookform/resolvers/zod";
import { CalendarIcon, IdCardLanyardIcon, LoaderIcon, RulerIcon } from "lucide-react";

import { Form, FormControl, FormField, FormItem, FormMessage } from "@/components/ui/form";
import { type CreateCharacterInput, createCharacterSchema } from "@/modules/identity/schemas";
import { IdentityInput } from "@/modules/identity/ui/components/identity-input";
import { Button } from "@/components/ui/button";
import { useCountries } from "@/modules/identity/api/use-countries";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

export const IdentityView = () => {
    const { visible } = useVisible("identity", false);

    const form = useForm<CreateCharacterInput>({
        resolver: zodResolver(createCharacterSchema),
        defaultValues: {
            firstName: "",
            lastName: "",
            birthDate: "",
            height: 180,
            gender: "mele",
            countryCode: "US"
        }
    });

    const { data: countries, isLoading, isError } = useCountries();

    const onSubmit = (values: CreateCharacterInput) => {
        fetchNui("/identity:submit", values);
    }

    return visible && (
        <div
            className="flex items-center justify-start p-10 w-full h-screen top-0 left-0 z-40 fixed"
            style={{
                backgroundImage: "radial-gradient(transparent, hsla(0 0% 0% / 0.6))"
            }}
        >
            <Form {...form}>
                <form
                    onSubmit={form.handleSubmit(onSubmit)}
                    className="w-[352px] flex flex-col gap-y-6 bg-neutral-900 p-7 rounded-xl border border-neutral-700"
                >
                    <span className="text-xl font-bold">
                        Nowa Postać
                    </span>
                    <FormField
                        control={form.control}
                        name="gender"
                        render={({ field }) => (
                            <FormItem>
                                <FormControl>
                                    <div className="grid grid-cols-2 gap-2.5">
                                        <Button className="rounded-md" type="button" variant={field.value === "mele" ? "default" : "secondary-two"} onClick={() => field.onChange("mele")}>
                                            Mężczyzna
                                        </Button>
                                        <Button className="rounded-md" type="button" variant={field.value === "famele" ? "default" : "secondary-two"} onClick={() => field.onChange("famele")}>
                                            Kobieta
                                        </Button>
                                    </div>
                                </FormControl>
                                <FormMessage />
                            </FormItem>
                        )}
                    />
                    <div className="flex flex-col gap-y-3.5">
                        <FormField
                            control={form.control}
                            name="firstName"
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <IdentityInput
                                            icon={IdCardLanyardIcon}
                                            placeholder="Imię"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <FormField
                            control={form.control}
                            name="lastName"
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <IdentityInput
                                            icon={IdCardLanyardIcon}
                                            placeholder="Nazwisko"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <FormField
                            control={form.control}
                            name="birthDate"
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <IdentityInput
                                            icon={CalendarIcon}
                                            placeholder="Data Urodzenia (DD/MM/RRRR)"
                                            {...field}
                                        />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <FormField
                            control={form.control}
                            name="height"
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        <div className="relative">
                                            <IdentityInput
                                                type="number"
                                                icon={RulerIcon}
                                                placeholder="Wzrost"
                                                className="pe-9"
                                                {...field}
                                            />
                                            <span className="text-sm font-medium text-muted-foreground absolute top-1/2 right-4 -translate-y-1/2 lowercase select-none">cm</span>
                                        </div>
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                        <FormField
                            control={form.control}
                            name="countryCode"
                            render={({ field }) => (
                                <FormItem>
                                    <FormControl>
                                        {(isLoading || isError) ? (
                                            <div className="border border-[hsla(0_0%_25%_/_0.5)] h-12 flex items-center justify-center rounded-lg !bg-[hsla(0_0%_15%_/_0.85)] w-full transition text-sm">
                                                {isLoading && <LoaderIcon className="animate-spin size-4" />}
                                                {isError && <p className="text-xs font-medium">Nie udało się pobrać listy krajów</p>}
                                            </div>
                                        ) : (
                                            <Select
                                                value={field.value}
                                                onValueChange={(value) => field.onChange(value)}
                                            >
                                                <SelectTrigger className="border border-[hsla(0_0%_25%_/_0.5)] px-3 !h-12 rounded-lg !bg-[hsla(0_0%_15%_/_0.85)] w-full outline-none focus:border-2 focus:border-neutral-600 transition text-sm">
                                                    <SelectValue placeholder="Kraj pochodzenia.." />
                                                </SelectTrigger>
                                                <SelectContent className="w-92 bg-neutral-800">
                                                    {countries?.map((country) => (
                                                        <SelectItem key={country.cca2} value={country.cca2}>
                                                            <img
                                                                src={country.flags.svg}
                                                                alt=""
                                                                className="w-5 rounded-xs shrink-0"
                                                            />
                                                            <span>{country.translations.pol.common}</span>
                                                        </SelectItem>
                                                    ))}
                                                </SelectContent>
                                            </Select>
                                        )}
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />
                    </div>
                    <Button type="submit" className="rounded-md">
                        Stwórz Postać
                    </Button>
                </form>
            </Form>
        </div>
    )
}